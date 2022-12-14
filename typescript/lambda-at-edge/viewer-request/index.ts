import type { CloudFrontRequestEvent, CloudFrontResponseResult, CloudFrontRequestResult } from 'aws-lambda';
import { DynamoDBClient, PutItemCommand, PutItemCommandInput } from "@aws-sdk/client-dynamodb";
import { marshall } from "@aws-sdk/util-dynamodb";
import {readFileSync} from 'fs';

const dynamodbClient = new DynamoDBClient({ region: 'eu-west-2' });

export const handler = async (event: CloudFrontRequestEvent): Promise<CloudFrontResponseResult | CloudFrontRequestResult> => {
  const request = event.Records[0].cf.request;
  if (request.method !== 'POST') {
    return request;
  }

  if (!request.body) {
    return {
      status: '400',
      statusDescription: 'Bad Request',
    }
  }

  const body = Buffer.from(request.body.data, 'base64').toString();
  const parsedData = new URLSearchParams(body);
  const username = parsedData.get("username")

  if (!username) {
    return {
      status: '400',
      statusDescription: 'Bad Request',
    }
  }

  const configJSON = readFileSync('./config.json')
  const config = JSON.parse(configJSON.toString())
  const input: PutItemCommandInput = {
    TableName: config.dynamodb_table_name,
    Item: marshall({
      'hash': username,
      'range': new Date().toISOString()
    })
  };

  const command =  new PutItemCommand(input)
  try {
    const results = await dynamodbClient.send(command);
    console.log(results)
    if (results.$metadata.httpStatusCode == 200) {
      return {
        status: '201',
        statusDescription: 'Created',
      }
    }
  } catch (err) {
    console.error(err)
  }

  return {
    status: '500',
    statusDescription: 'Internal Server Error',
  }
};