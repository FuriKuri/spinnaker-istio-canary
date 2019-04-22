package main

import (
	"bytes"
	"context"
	"html/template"
	"io/ioutil"
	"net/http"
	"net/http/httputil"
	"os"
	"strings"
	"cloud.google.com/go/compute/metadata"
)

type Instance struct {
	Name        string
	Color       string
	Version     string
	Zone        string
	Project     string
	InternalIP  string
	ExternalIP  string
	LBRequest   string
	ClientIP    string
	PodName     string
	SuccessRate string
	Error       string
}

func Page(r *http.Request) string {
	tpl := template.Must(template.New("out").Parse(html))
	i := MetaData(r)
	var buf bytes.Buffer
	tpl.Execute(&buf, i)
	return buf.String()
}

func MetaData(r *http.Request) *Instance {
	instance := newInstance(r.Context())
	raw, _ := httputil.DumpRequest(r, true)
	instance.LBRequest = string(raw)
	instance.ClientIP = r.RemoteAddr
	instance.Version = os.Getenv("VERSION")
	instance.SuccessRate = os.Getenv("SUCCESS_RATE")
	instance.PodName = os.Getenv("HOSTNAME")
	instance.Color = getColor(os.Getenv("VERSION"))
	return instance
}

func newInstance(ctx context.Context) *Instance {
	var i = new(Instance)
	if !metadata.OnGCE() {
		i.Error = "Not running on GCE"
		return i
	}

	i.Error = "None"
	i.Zone = getMetaData(ctx, "instance/zone")
	i.Name = getMetaData(ctx, "instance/name")
	i.Project = getMetaData(ctx, "project/project-id")
	i.InternalIP = getMetaData(ctx, "instance/network-interfaces/0/ip")
	i.ExternalIP = getMetaData(ctx, "instance/network-interfaces/0/access-configs/0/external-ip")
	
	return i
}

func getColor(version string) string {
	if strings.Contains(version, "baseline") {
		return "orange"
	} else if strings.Contains(version, "canary") {
		return "red"
	} else {
		return "blue"
	}
}


func getMetaData(ctx context.Context, path string) string {
	metaDataURL := "http://metadata/computeMetadata/v1/"
	req, _ := http.NewRequest(
		"GET",
		metaDataURL+path,
		nil,
	)
	req.Header.Add("Metadata-Flavor", "Google")
	req = req.WithContext(ctx)
	return string(makeRequest(req))
}

func makeRequest(r *http.Request) []byte {
	transport := http.Transport{DisableKeepAlives: true}
	client := &http.Client{Transport: &transport}
	resp, err := client.Do(r)
	if err != nil {
		message := "Unable to call backend: " + err.Error()
		panic(message)
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		message := "Unable to read response body: " + err.Error()
		panic(message)
	}
	return body
}
