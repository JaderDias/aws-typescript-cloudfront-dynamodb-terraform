import 'mocha';
import { expect } from 'chai';
import lambdaTester from 'lambda-tester';
import proxyquire from 'proxyquire';
import sinon from 'sinon';

describe('index', function () {
  const dynamoDbStub = {
    send: sinon.stub()
  };
  const AWSStub = {
    DynamoDBClient: sinon.stub().returns(dynamoDbStub)
  };
  const lambda = proxyquire('../index', {
    '@aws-sdk/client-dynamodb': AWSStub
  });
  describe('.handler', function () {
    it('get', function () {

      const event = {
        Records: [
          {
            cf:
            {
              request: {
                method: "GET",
                body: { data: "" }
              }
            }
          }
        ]
      };

      const expectedResult = event.Records[0].cf.request;

      return lambdaTester(lambda.handler)
        .event(event)
        .expectResult(function (result) {
          expect(result).to.be.deep.equal(expectedResult);
        });
    });

    it('sucessful post', function () {
      dynamoDbStub.send.resolves({
        '$metadata': {
          httpStatusCode: 200,
          requestId: '020TTSBN76KJAQUKK3BPJMAJHJVV4KQNSO5AEMVJF66Q9ASUAAJG',
          attempts: 1,
          totalRetryDelay: 0
        }
      });
      let event = {
        Records: [
          {
            cf:
            {
              request: {
                method: "POST",
                body: { data: btoa("username=Bob") }
              }
            }
          }
        ]
      };

      let expectedResult = {
        status: '201',
        statusDescription: 'Created',
      };

      return lambdaTester(lambda.handler)
        .event(event)
        .expectResult(function (result) {
          expect(result).to.be.deep.equal(expectedResult);
        });
    });

    it('bad post', function () {
      let event = {
        Records: [
          {
            cf:
            {
              request: {
                method: "POST",
                body: { data: Buffer.from("username=Bob", 'base64') }
              }
            }
          }
        ]
      };

      let expectedResult = {
        status: '400',
        statusDescription: 'Bad Request',
      };

      return lambdaTester(lambda.handler)
        .event(event)
        .expectResult(function (result) {
          expect(result).to.be.deep.equal(expectedResult);
        });
    });

    it('failed post', function () {
      dynamoDbStub.send.resolves({
        '$metadata': {
          httpStatusCode: 500,
          requestId: '020TTSBN76KJAQUKK3BPJMAJHJVV4KQNSO5AEMVJF66Q9ASUAAJG',
          attempts: 1,
          totalRetryDelay: 0
        }
      });
      let event = {
        Records: [
          {
            cf:
            {
              request: {
                method: "POST",
                body: { data: btoa("username=Bob") }
              }
            }
          }
        ]
      };

      let expectedResult = {
        status: '500',
        statusDescription: 'Internal Server Error',
      };

      return lambdaTester(lambda.handler)
        .event(event)
        .expectResult(function (result) {
          expect(result).to.be.deep.equal(expectedResult);
        });
    });

    it('exceptional post', function () {
      dynamoDbStub.send.throws();
      let event = {
        Records: [
          {
            cf:
            {
              request: {
                method: "POST",
                body: { data: btoa("username=Bob") }
              }
            }
          }
        ]
      };

      let expectedResult = {
        status: '500',
        statusDescription: 'Internal Server Error',
      };

      return lambdaTester(lambda.handler)
        .event(event)
        .expectResult(function (result) {
          expect(result).to.be.deep.equal(expectedResult);
        });
    });
  });
});