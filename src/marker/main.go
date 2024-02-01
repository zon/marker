package main

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"os"
	"path"
	"strings"

	"github.com/alecthomas/kong"
	"github.com/cbroglie/mustache"
	"github.com/yuin/goldmark"
	"gopkg.in/yaml.v3"
)

const staticPrefix string = "/static/"
const defaultTemplate string = "layout.html.mustache"
const defaultStyle string = "/static/layout.css"

var cli struct {
	Port      string `help:"Listen on port." default:"8080"`
	Content   string `type:"existingdir" help:"Markdown content directory." default:"content"`
	Templates string `type:"existingdir" help:"Mustache template directory." default:"templates"`
	Static    string `type:"existingdir" help:"Static file directory." default:"static"`
	Log       bool   `help:"Log requests."`
}

type Header struct {
	Title  string
	Layout string
	Style  string
}

type TemplateValues struct {
	Title string
	Style string
	Body  string
}

func main() {
	kong.Parse(&cli)

	fs := http.FileServer(http.Dir(cli.Static))
	http.Handle(staticPrefix, http.StripPrefix(staticPrefix, fs))
	http.HandleFunc("/", renderResponse)

	address := fmt.Sprintf(":%s", cli.Port)
	fmt.Println("Listening on", address, "...")
	err := http.ListenAndServe(address, nil)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
	}
}

func renderResponse(w http.ResponseWriter, r *http.Request) {
	if cli.Log {
		fmt.Println(r.Method, r.URL)
	}

	fileName := strings.TrimPrefix(fmt.Sprintf("%s.md", r.URL), "/")
	if r.URL.Path == "/" {
		fileName = "index.md"
	}

	dat, err := os.ReadFile(path.Join(cli.Content, fileName))
	if err != nil {
		writeError(w, err)
		return
	}

	header := Header{}
	halves := strings.Split(string(dat), "^^^")
	if len(halves) > 1 {
		err := yaml.Unmarshal([]byte(halves[0]), &header)
		if err != nil {
			writeError(w, err)
			return
		}
	}
	dat = []byte(halves[len(halves)-1])

	var body bytes.Buffer
	err = goldmark.Convert(dat, &body)
	if err != nil {
		writeError(w, err)
		return
	}

	title := fileName
	if header.Title != "" {
		title = header.Title
	}

	style := defaultStyle
	if header.Style != "" {
		style = header.Style
	}

	values := TemplateValues{
		Title: title,
		Style: style,
		Body:  strings.TrimSpace(body.String()),
	}

	templatePath := defaultTemplate
	if header.Layout != "" {
		templatePath = header.Layout
	}
	templatePath = path.Join(cli.Templates, templatePath)
	html, err := mustache.RenderFile(templatePath, values)
	if err != nil {
		writeError(w, err)
		return
	}
	io.WriteString(w, html)
}

func writeError(w http.ResponseWriter, err error) {
	w.WriteHeader(http.StatusInternalServerError)
	io.WriteString(w, err.Error())
}
