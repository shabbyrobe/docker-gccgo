docker-gccgo
============

This was a little experiment to see if some of my projects work properly with
gccgo. I used Docker because I didn't want any risk of this leaking out into my
main system and making a mess of anything else, but now that I've worked with it
a bit and know the extent of the risk to my functioning work machine, I'll probably
just make a bash script that does a compile with a custom `--prefix` without
Docker at some point.

If you try to build something with this, it may not run on your host system
using the default arguments as the correct `libgo.so` version is dynamically
linked but will only be available in the container. I recommend using the `-static`
flag (`./gccgo -static -o main main.go` or `./gccgogo build -gccoflags static`).


## Expectation management

This is exactly as much Dockerfile and bash as I need to scratch my own itch.
It's more an experimental notepad than a working piece of software, so it
it may not work for you (or at all, for that matter) and is subject to change
at any time.

If it's something you think would be useful in your own projects, I encourage
you to vendor it into your own scripts and modify it to suit your own needs.
