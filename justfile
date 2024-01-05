# Copyright 2018-2020 Cargill Incorporated
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


crates := '\
    libtransact \
    examples/simple_xo \
    examples/address_generator \
    examples/sabre_command \
    examples/sabre_smallbank \
    examples/sabre_command_executor\
    cli \
    '

crates_wasm := '\
    examples/sabre_command \
    examples/sabre_smallbank \
    '

features := '\
    --features=experimental \
    --features=stable \
    --features=default \
    --no-default-features \
    '

build:
    #!/usr/bin/env sh
    set -e
    for feature in $(echo {{features}})
    do
        for crate in $(echo {{crates}})
        do
            cmd="cargo build --tests --manifest-path=$crate/Cargo.toml $BUILD_MODE $feature"
            echo "\033[1m$cmd\033[0m"
            RUSTFLAGS="-D warnings" $cmd
        done
    done
    cmd="cargo build --tests --manifest-path=libtransact/Cargo.toml --features=sawtooth-compat"
    echo "\033[1m$cmd\033[0m"
    RUSTFLAGS="-D warnings" $cmd
    cmd="cargo build --tests --manifest-path=libtransact/Cargo.toml --features=experimental,state-merkle-sql-postgres-tests"
    echo "\033[1m$cmd\033[0m"
    RUSTFLAGS="-D warnings" $cmd
    $cmd
    for feature in $(echo {{features}})
    do
        for crate in $(echo {{crates_wasm}})
        do
            cmd="cargo build --tests --target wasm32-unknown-unknown --manifest-path=$crate/Cargo.toml $BUILD_MODE $feature"
            echo "\033[1m$cmd\033[0m"
            RUSTFLAGS="-D warnings" $cmd
            $cmd
        done
    done
    echo "\n\033[92mBuild Success\033[0m\n"

clean:
    cargo clean

doc:
    #!/usr/bin/env sh
    set -e
    cargo doc \
        --manifest-path libtransact/Cargo.toml \
        --features stable,experimental \
        --no-deps

lint:
    #!/usr/bin/env sh
    set -e
    echo "\033[1mcargo fmt -- --check\033[0m"
    cargo fmt -- --check
    for feature in $(echo {{features}})
    do
        for crate in $(echo {{crates}})
        do
            cmd="cargo clippy --manifest-path=$crate/Cargo.toml $feature -- -D warnings"
            echo "\033[1m$cmd\033[0m"
            $cmd
        done
    done
    echo "\n\033[92mLint Success\033[0m\n"

test: build
    #!/usr/bin/env sh
    set -e
    for feature in $(echo {{features}})
    do
        for crate in $(echo {{crates}})
        do
            cmd="cargo test --manifest-path=$crate/Cargo.toml $TEST_MODE $feature"
            echo "\033[1m$cmd\033[0m"
            $cmd
        done
    done
    echo "\n\033[92mTest Success\033[0m\n"
