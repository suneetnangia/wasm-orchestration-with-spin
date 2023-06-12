FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/eventprocessor
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/eventprocessor/spin.toml .
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/eventprocessor/target/wasm32-wasi/release/eventprocessor.wasm ./target/wasm32-wasi/release/eventprocessor.wasm
