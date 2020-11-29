import numpy as np
import librosa
import librosa.display

majorscales = {'C': [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1],
               'C#': [1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0],
               'D': [0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1],
               'Eb': [1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1, 0],
               'E': [0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1],
               'F': [1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1, 0],
               'F#': [0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 1],
               'G': [1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1],
               'Ab': [1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0],
               'A': [0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1],
               'Bb': [1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0],
               'B': [0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1]}


class Audio(object):
    def __init__(self, loadedAudio):
        self.wav = loadedAudio[0]
        self.samplefreq = loadedAudio[1]

        if self.wav.dtype == 'int16':
            self.wav = self.wav / (2.0 ** 15)
        self.channels = 1
        self.sample_points = self.wav.shape[0]
        self.audio_length_seconds = self.sample_points / self.samplefreq
        self.time_array_seconds = np.arange(0, self.sample_points, 1) / self.samplefreq
        self.tempo_bpm = librosa.beat.beat_track(y=self.wav, sr=self.samplefreq)[0]
        self.beat_frames = librosa.beat.beat_track(y=self.wav, sr=self.samplefreq)[1]
        self.beat_times = librosa.frames_to_time(self.beat_frames, sr=self.samplefreq)
        self.rolloff_freq = np.mean(
            librosa.feature.spectral_rolloff(y=self.wav, sr=self.samplefreq, hop_length=512, roll_percent=0.9))

    def getZeroCrossingRates(self):
        zcrs = librosa.feature.zero_crossing_rate(y=self.wav, frame_length=2048, hop_length=512)
        return zcrs

    def plotSpectrogram(self, mels=512, maxfreq=30000):
        mel = librosa.feature.melspectrogram(y=self.wav, sr=self.samplefreq, n_mels=mels, fmax=maxfreq)
        librosa.display.specshow(librosa.amplitude_to_db(mel, ref=np.max), y_axis='mel', fmax=maxfreq, x_axis='time')
        return mel

    def plotTempogram(self):
        oenv = librosa.onset.onset_strength(y=self.wav, sr=self.samplefreq, hop_length=512)
        tempogram = librosa.feature.tempogram(onset_envelope=oenv, sr=self.samplefreq, hop_length=512)
        return tempogram

    def findTonicAndKey(self):
        chromagram = librosa.feature.chroma_stft(y=self.wav, sr=self.samplefreq)
        chromasums = []
        for i, a in enumerate(chromagram):
            chromasums.append(np.sum(chromagram[i]))
        tonicval = np.where(max(chromasums) == chromasums)[0][0]
        notes = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
        tonic = notes[tonicval]
        z_dist_avg_to_tonic = round((max(chromasums) - np.mean(chromasums)) / np.std(chromasums), 4)
        bestmatch = 0
        bestmatchid = 0
        for key, scale in majorscales.items():
            corr = np.corrcoef(scale, chromasums)[0, 1]
            if corr > bestmatch:
                bestmatch = corr
                bestmatchid = key
        if tonic != bestmatchid:
            keysig = tonic + ' Minor'
        else:
            keysig = tonic + ' Major'
        return tonic, keysig, z_dist_avg_to_tonic


def decode_audio(filename):
    song = Audio(librosa.load(filename, mono=True))
    wavfeatures = dict()
    wavfeatures['audio_file_id'] = filename.split('/')[-1]
    wavfeatures['samplefreq'] = song.samplefreq
    wavfeatures['channels'] = song.channels
    wavfeatures['sample_points'] = song.sample_points
    wavfeatures['audio_length_seconds'] = round(song.audio_length_seconds, 4)
    wavfeatures['tempo_bpm'] = song.tempo_bpm
    wavfeatures['avg_diff_beat_times'] = round(
        np.mean(song.beat_times[1:] - song.beat_times[0:len(song.beat_times) - 1]), 4)
    wavfeatures['std_diff_beat_times'] = round(
        np.std(song.beat_times[1:] - song.beat_times[0:len(song.beat_times) - 1]), 4)
    wavfeatures['rolloff_freq'] = round(song.rolloff_freq, 0)
    wavfeatures['avg_zcr'] = round(np.mean(song.getZeroCrossingRates()), 4)
    wavfeatures['zcr_range'] = np.max(song.getZeroCrossingRates()) - np.min(song.getZeroCrossingRates())
    wavfeatures['avg_mel_freq'] = round(np.mean(song.plotSpectrogram()), 4)
    wavfeatures['std_mel_freq'] = round(np.std(song.plotSpectrogram()), 4)
    wavfeatures['avg_onset_strength'] = round(np.mean(song.plotTempogram()), 4)
    wavfeatures['std_onset_strength'] = round(np.std(song.plotTempogram()), 4)
    wavfeatures['tonic'] = song.findTonicAndKey()[0]
    wavfeatures['key_signature'] = song.findTonicAndKey()[1]
    wavfeatures['z_dist_avg_to_tonic'] = song.findTonicAndKey()[2]
    return wavfeatures
