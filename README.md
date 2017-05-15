Alpine Linux PGP-Verified Docker Image
--------------------------------------



Building the image
------------------

In order to build this image do: 

```
make
```

This makefile will:

- Download the filesystem payload from alpinelinux.org
- Verify the signature of the filesystem payload.
- Trigger the build process of the Docker image.
- Push the image to your favority repository.

Outside of the scope:

- Verify the integrity of the image once pulled from the repository.

Tested Platforms
----------------

- x86_64
