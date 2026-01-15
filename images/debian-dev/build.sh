#!/bin/bash

set -ex

bunx oh-my-opencode install --no-tui --claude=no --chatgpt=no --gemini=no
npm install -g @studyzy/openspec-cn@latest
