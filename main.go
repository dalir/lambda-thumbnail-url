package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/cloudfront/sign"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
	"github.com/sirupsen/logrus"
	"os"
	"strings"
	"time"
)

type Dataset struct {
	UUID       string `json:"dataset_uuid"`
	PhotoName  string `json:"photo_name"`
	privateKey string
	SignedURL  string `json:"thumbnail_signed_url"`
}

func (dataset *Dataset) getPrivateKey() (err error) {
	ctxLog.Printf("Search For Thumb and Copy...")

	cfg, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		return
	}
	// stsSvc := sts.NewFromConfig(cfg)
	// stsCredProvider := stscreds.NewAssumeRoleProvider(stsSvc, "arn:aws:iam::942381384083:role/skyapi-v2-stage-terraform")

	// cfg.Credentials = aws.CredentialsProvider(stsCredProvider)

	ssmClient := ssm.NewFromConfig(cfg)
	param, err := ssmClient.GetParameter(context.TODO(), &ssm.GetParameterInput{
		Name:           aws.String(os.Getenv("AWS_SSM_PARAM")),
		WithDecryption: aws.Bool(true),
	})
	if err != nil {
		return
	}

	dataset.privateKey = *param.Parameter.Value
	return
}

func (dataset *Dataset) createSignedURL() (err error) {
	privKey, err := sign.LoadPEMPrivKey(strings.NewReader(dataset.privateKey))
	if err != nil {
		return
	}
	signer := sign.NewURLSigner(os.Getenv("AWS_CF_KEY_ID"), privKey)
	dataset.SignedURL, err = signer.Sign(os.Getenv("AWS_CF_URL")+"/"+dataset.UUID+"/thumbnails/"+dataset.PhotoName, time.Now().Add(1*time.Hour))
	return
}

func (dataset *Dataset) Run() (err error) {
	if err = dataset.getPrivateKey(); err != nil {
		return
	}

	if err = dataset.createSignedURL(); err != nil {
		return
	}
	return
}

var log *logrus.Logger
var ctxLog *logrus.Entry

func init() {
	log = logrus.New()
	ctxLog = log.WithFields(logrus.Fields{})
}

// func handleRequest(input Dataset) (output Dataset, err error) {
func handleRequest(ctx context.Context, input Dataset) (output Dataset, err error) {
	log.SetFormatter(&logrus.JSONFormatter{})
	log.SetLevel(logrus.DebugLevel)
	ctxLog = log.WithFields(logrus.Fields{
		"uuid": input.UUID,
	})
	output = input
	if err = output.Run(); err != nil {
		err = fmt.Errorf(`{"Report": "Run failed:  %v"}`, err.Error())
		return
	}
	ctxLog.Printf(output.SignedURL)
	return
}

func main() {
	/*
		in := Dataset{
			UUID:      "ba616f35-a1fd-4758-856e-f695f65d3057",
			PhotoName: "1666193654000_c59106150ef7eb8a7e41e077611f5968_512.jpg",
		}
		handleRequest(in)

	*/
	lambda.Start(handleRequest)

}
