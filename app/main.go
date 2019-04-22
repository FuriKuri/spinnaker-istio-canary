package main

import (
    "net/http"
    "math/rand"
    "log"
    "os"
    "strconv"
    "github.com/prometheus/client_golang/prometheus/promhttp"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/gorilla/mux"
)

var counter = prometheus.NewCounterVec(prometheus.CounterOpts{
		Name:      "requests",
		Help:      "Number of requests served, by http code.",
	}, []string{"http_code"})

type httpHandler struct {
}

func MetaHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte(Page(r)))
}

func DefaultHandler(w http.ResponseWriter, r *http.Request) {
	if rand.Intn(100) >= rate() {
		counter.WithLabelValues("500").Inc()
		w.WriteHeader(http.StatusInternalServerError)
    	w.Write([]byte("500 - Something bad happened!\n"))
	} else {
		counter.WithLabelValues("200").Inc()
		w.WriteHeader(http.StatusOK)
    	w.Write([]byte("200 - Hello World!\n"))
	}
}

func main() {
	prometheus.MustRegister(counter)
	
    go func() {
			http.ListenAndServe(":8000", promhttp.Handler())
	}()

	r := mux.NewRouter()
	r.HandleFunc("/", DefaultHandler)
    r.HandleFunc("/meta", MetaHandler)
	http.ListenAndServe(":8080", r)
}

func rate() int {
    value := os.Getenv("SUCCESS_RATE")
    if len(value) == 0 {
        return 100
    }
    rate, err := strconv.Atoi(value)
    if err != nil {
    	log.Fatal(err)
	}
    return rate
}
