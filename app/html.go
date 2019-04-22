package main

const (
	html = `<!doctype html>
<html>
<head>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.0/css/materialize.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.97.0/js/materialize.min.js"></script>
<title>🐦 Canary App 🐦</title>
</head>
<body>
<div class="container">
<div class="row">
<div class="col s2">&nbsp;</div>
<div class="col s8">
<div class="card {{.Color}}">
<div class="card-content white-text">
<div class="card-title">🐦 Canary App 🐦</div>
</div>
<div class="card-content white">
<table class="bordered">
  <tbody>
	<tr>
	  <td>Pod Name</td>
	  <td>{{.PodName}}</td>
	</tr>
	<tr>
	  <td>Node Name</td>
	  <td>{{.Name}}</td>
	</tr>
	<tr>
	  <td>Version</td>
	  <td>{{.Version}}</td>
	</tr>
	<tr>
	  <td>Zone</td>
	  <td>{{.Zone}}</td>
	</tr>
	<tr>
	  <td>Project</td>
	  <td>{{.Project}}</td>
	</tr>
	<tr>
	  <td>Node Internal IP</td>
	  <td>{{.InternalIP}}</td>
	</tr>
	<tr>
	  <td>Node External IP</td>
	  <td>{{.ExternalIP}}</td>
	</tr>
	<tr>
	  <td>Success Rate</td>
	  <td>{{.SuccessRate}}</td>
	</tr>
  </tbody>
</table>
</div>
</div>

<div class="col s2">&nbsp;</div>
</div>
</div>
</html>`
)
