import pandas as pd
import numpy as np

from sklearn.preprocessing import OneHotEncoder, MinMaxScaler

notes = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
notes_key = ['C Minor', 'C# Minor', 'D Minor', 'Eb Minor', 'E Minor', 'F Minor', 'F# Minor', 'G Minor',
             'Ab Minor', 'A Minor', 'Bb Minor', 'B Minor',
             'C Major', 'C# Major', 'D Major', 'Eb Major', 'E Major', 'F Major',
             'F# Major', 'G Major', 'Ab Major', 'A Major', 'Bb Major', 'B Major']

tonic_enc = OneHotEncoder(categories='auto', handle_unknown='ignore', sparse=False)
tonic = np.array(notes).reshape(-1, 1)
fitted_tonic = tonic_enc.fit(tonic)

notes_key_enc = OneHotEncoder(categories='auto', handle_unknown='ignore', sparse=False)
notes_key = np.array(notes_key).reshape(-1, 1)
fitted_notes_key = notes_key_enc.fit(notes_key)

scaler = MinMaxScaler(copy=True)


def preprocessing(data):
    df = pd.DataFrame([data])
    df.drop(labels=['samplefreq', 'channels', 'sample_points', 'audio_length_seconds'], axis=1, inplace=True)
    tonic_col = df["tonic"].to_numpy().reshape(-1, 1)
    df = df.drop(columns=['tonic'])
    tonic_col = fitted_tonic.transform(tonic_col)
    key_signature_col = df["key_signature"].to_numpy().reshape(-1, 1)
    df = df.drop(columns=['key_signature'])
    key_signature_col = fitted_notes_key.transform(key_signature_col)
    tempo_bpm = df['tempo_bpm'].to_numpy()
    rolloff_freq = df['rolloff_freq'].to_numpy()
    avg_mel_freq = df['avg_mel_freq'].to_numpy()
    std_mel_freq = df['std_mel_freq'].to_numpy()
    z_dist_avg_to_tonic = df['z_dist_avg_to_tonic'].to_numpy()
    df = df.drop(
        columns=['tempo_bpm', 'rolloff_freq', 'avg_mel_freq', 'std_mel_freq', 'std_mel_freq', 'z_dist_avg_to_tonic'])
    tempo_bpm = scaler.fit_transform(tempo_bpm.reshape(-1, 1))
    rolloff_freq = scaler.fit_transform(rolloff_freq.reshape(-1, 1))
    avg_mel_freq = scaler.fit_transform(avg_mel_freq.reshape(-1, 1))
    std_mel_freq = scaler.fit_transform(std_mel_freq.reshape(-1, 1))
    z_dist_avg_to_tonic = scaler.fit_transform(z_dist_avg_to_tonic.reshape(-1, 1))

    tempo_bpm = scaler.fit_transform(tempo_bpm.reshape(-1, 1))
    rolloff_freq = scaler.fit_transform(rolloff_freq.reshape(-1, 1))
    avg_mel_freq = scaler.fit_transform(avg_mel_freq.reshape(-1, 1))
    std_mel_freq = scaler.fit_transform(std_mel_freq.reshape(-1, 1))
    z_dist_avg_to_tonic = scaler.fit_transform(z_dist_avg_to_tonic.reshape(-1, 1))
    X = df.drop(columns=["audio_file_id"]).to_numpy()
    X = np.hstack(
        [X, tempo_bpm, rolloff_freq, avg_mel_freq, std_mel_freq, z_dist_avg_to_tonic, tonic_col, key_signature_col])
    return X
