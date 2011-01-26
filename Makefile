.PHONY: deps rel

compile: deps
	rebar compile

rel: compile
	rebar generate

deps:
	rebar get-deps

clean:
	rebar clean
