#!/bin/bash
# Converts all .jpg, .jpeg, and .png files in images/ to .tga
# in the media/ folder using ImageMagick.
# Fills in missing numbers first, then continues from the highest existing number.

MEDIA_DIR="./media"
IMAGE_DIR="./images"
HASH_FILE="./.converted_hashes"
mkdir -p "$MEDIA_DIR" "$IMAGE_DIR"
touch "$HASH_FILE"

# Load previously converted hashes
declare -A converted_hashes
while IFS= read -r line; do
    [[ -n "$line" ]] && converted_hashes["$line"]=1
done < "$HASH_FILE"

# Collect all existing numbers from media/
declare -A existing
max=0
for f in "$MEDIA_DIR"/*.tga; do
    [[ -f "$f" ]] || continue
    num=$(basename "$f" .tga)
    if [[ "$num" =~ ^[0-9]+$ ]]; then
        existing[$num]=1
        (( num > max )) && max=$num
    fi
done

# Build list of missing numbers (gaps in 1..max)
missing=()
for (( i=1; i<=max; i++ )); do
    if [[ -z "${existing[$i]}" ]]; then
        missing+=("$i")
    fi
done

echo "Existing files: 1-$max (${#existing[@]} files)"
echo "Missing numbers: ${missing[*]:-none}"
echo ""

# Gather input images from images/
inputs=()
for ext in jpg jpeg png; do
    for f in "$IMAGE_DIR"/*."$ext" "$IMAGE_DIR"/*."${ext^^}" "$IMAGE_DIR"/*."${ext^}"; do
        [[ -f "$f" ]] && inputs+=("$f")
    done
done

# Deduplicate (in case of case-insensitive filesystem)
declare -A seen
unique_inputs=()
for f in "${inputs[@]}"; do
    lower="${f,,}"
    if [[ -z "${seen[$lower]}" ]]; then
        seen[$lower]=1
        unique_inputs+=("$f")
    fi
done
inputs=("${unique_inputs[@]}")

# Filter out already-converted images by MD5 hash
new_inputs=()
declare -A input_hashes
for f in "${inputs[@]}"; do
    hash=$(md5sum "$f" | awk '{print $1}')
    if [[ -z "${converted_hashes[$hash]}" ]]; then
        new_inputs+=("$f")
        input_hashes["$f"]="$hash"
    else
        echo "  Skipping (already converted): $f"
    fi
done
inputs=("${new_inputs[@]}")

if [[ ${#inputs[@]} -eq 0 ]]; then
    echo "No .jpg, .jpeg, or .png files found in $IMAGE_DIR/"
    exit 0
fi

echo "Found ${#inputs[@]} image(s) to convert."

# Assign numbers: fill gaps first, then continue from max+1
gap_idx=0
next=$((max + 1))
converted=0

for img in "${inputs[@]}"; do
    if (( gap_idx < ${#missing[@]} )); then
        num=${missing[$gap_idx]}
        ((gap_idx++))
    else
        num=$next
        ((next++))
    fi

    out="$MEDIA_DIR/$num.tga"
    echo "  $img -> $out"
    magick "$img" -resize 256x256! "$out"
    if [[ $? -eq 0 ]]; then
        ((converted++))
        # Record hash so we don't convert this image again
        echo "${input_hashes[$img]}" >> "$HASH_FILE"
    else
        echo "  ERROR: Failed to convert $img"
    fi
done

echo ""
echo "Converted $converted file(s)."

# Determine new max
new_max=$(( next - 1 ))
if (( gap_idx < ${#missing[@]} )); then
    new_max=$max
fi
(( new_max < max )) && new_max=$max

echo ""
echo "Updating NUM_IMAGES in ReadyCheckMemes.lua to: $new_max"

sed -i.bak -E "s/^(NUM_IMAGES\s*=\s*)[0-9]+/\1$new_max/" ReadyCheckMemes.lua
