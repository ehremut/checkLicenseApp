import json
import requests

from flask import Flask, request
from lxml import html

app = Flask(__name__)


@app.route('/get_cover')
def recommendation():
    path = request.args.get('url')
    if not path:
        response = app.response_class(
            status=404,
        )
        return response
    resp = requests.get(path)
    tree = html.fromstring(resp.content)

    img = tree.xpath('(//source)[2]')
    if len(img) == 1:
        img = img[0].attrib['srcset']
        url = img.split(" ")[0]
        response = app.response_class(
            response=json.dumps({"URL": url}),
            status=200,
            mimetype='application/json'
        )
        return response
    response = app.response_class(
        status=404,
    )
    return response


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8085)
