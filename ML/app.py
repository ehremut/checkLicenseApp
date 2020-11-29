import annoy
import json

from storage import Storage
from recommendation import decode_audio
from preprocessing import preprocessing
from flask import Flask, request

app = Flask(__name__)
annoy_tree = annoy.AnnoyIndex(47, 'manhattan')
annoy_tree.load('index.tree')
storage = Storage("songs.db")


@app.route('/recommendation')
def recommendation():
    path = request.args.get('path')
    data = decode_audio(path)
    X = preprocessing(data)
    neuboors = annoy_tree.get_nns_by_vector(X.reshape(47, 1), 5, search_k=-1, include_distances=False)
    json_data = storage.get_all_song_name(neuboors)
    response = app.response_class(
        response=json.dumps(json_data),
        status=200,
        mimetype='application/json'
    )
    return response


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8085)
