# projectm-wasm

[projectM](https://github.com/projectM-visualizer/projectm), the open-source MilkDrop visualizer, compiled to WebAssembly for [Koel](https://github.com/koel/koel).

This repo holds a small C wrapper around projectM's API (`src/koel_projectm.cpp`) and the script that builds both into `koel_projectm.js` and `koel_projectm.wasm`. Koel loads these files at runtime when you open its projectM visualizer.

## Build

You need Docker.

```sh
./build.sh
```

The files land in `dist/`. Set `PROJECTM_VERSION` to build another projectM tag (default: `v4.1.8`).

Each `v*` tag pushed to this repo publishes the two files as release assets and to npm as [`@koel-project/projectm-wasm`](https://www.npmjs.com/package/@koel-project/projectm-wasm). The package version is this wrapper's own; it bundles projectM v4.1.8.

## Using your own build

Koel serves the files from `public/visualizer/projectm/`. Build your own copy, with your own changes to projectM or the wrapper if you like, and replace the two files there.

## License

LGPL-2.1, the same as projectM. See [LICENSE](LICENSE).
