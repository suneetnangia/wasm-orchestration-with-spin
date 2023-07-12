FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/fulfilmentprocessor
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/fulfilmentprocessor/spin.toml .
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/fulfilmentprocessor/target/wasm32-wasi/release/fulfilmentprocessor.wasm ./target/wasm32-wasi/release/fulfilmentprocessor.wasm
