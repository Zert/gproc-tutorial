.PHONY: deps rel

compile: deps
	./rebar compile

rel: compile
	./rebar generate

deps:
	./rebar get-deps

clean:
	./rebar clean

devrel: dev1 dev2

dev1 dev2:
	mkdir -p dev
	(cd rel && ../rebar generate target_dir=../dev/$@ overlay_vars=vars/$@_vars.config)

devclean:
	rm -rf dev
