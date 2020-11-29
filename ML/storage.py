from sqlalchemy import func
from sqlalchemy import create_engine, Column, Integer, TEXT
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()


class Songs(Base):
    __tablename__ = "songs"
    id = Column(Integer, primary_key=True)
    filename = Column(TEXT)
    artist = Column(TEXT)
    title = Column(TEXT)
    album = Column(TEXT)


class Storage:
    def __init__(self, url: str) -> None:
        self.engine = create_engine(f'sqlite:///{url}', echo=False)
        Base.metadata.create_all(self.engine)
        session = sessionmaker(bind=self.engine)
        self.session = session()

    def insert_song(self, filename, artist, title, album):
        max_id = self.session.query(func.max(Songs.id)).scalar()
        song_id = max_id + 1 if max_id is not None else 0
        new_song = Songs(id=song_id, filename=filename, artist=artist, title=title, album=album)
        self.session.add(new_song)
        self.session.commit()

    def get_song_name(self, song_id):
        result = self.session.query(Songs.filename, Songs.artist, Songs.title, Songs.album)\
            .filter(Songs.id == song_id).first()
        if result is None:
            return None
        json_data = {
            'filename': result[0],
            'artist': result[1],
            'title': result[2],
            'album': result[3]
        }
        return json_data

    def get_all_song_name(self, song_ids):
        result = []
        for song_id in song_ids:
            data = self.get_song_name(song_id)
            if data is not None:
                result.append(data)
        return result
