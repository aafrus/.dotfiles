#!/bin/bash
# Creates ~/hub directory structure

dirs=(
    hub/school/courses
    hub/school/docs/context
    hub/school/docs/notes
    hub/school/docs/readmes
    hub/personal/homelab
    hub/personal/learning
    hub/personal/sandbox
    hub/personal/obsidian
    hub/personal/websites
    hub/personal/docs/context
    hub/personal/docs/notes
    hub/personal/docs/readmes
    hub/work/docs/context
    hub/work/docs/notes
    hub/work/docs/readmes
    hub/media/music
    hub/media/pictures
    hub/media/videos
    hub/downloads
    hub/archive
    hub/projects
)

for dir in "${dirs[@]}"; do
    mkdir -p "$HOME/$dir"
done

echo "~/hub structure created"
