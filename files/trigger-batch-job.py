import requests


def lambda_handler(event, context):
    data = {'some': 'data'}
    headers = {'x-api-key': '${api_key}'}
    url = '${endpoint}'
    print('Sending archive batch job request...')
    response = requests.post(url=url, data=data, headers=headers)
    print('Response is ' + response.text)
