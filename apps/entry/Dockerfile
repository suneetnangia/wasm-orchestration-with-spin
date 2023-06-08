FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/entry
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/entry/spin.toml .
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/entry/target/wasm32-wasi/release/entry.wasm ./target/wasm32-wasi/release/entry.wasm
