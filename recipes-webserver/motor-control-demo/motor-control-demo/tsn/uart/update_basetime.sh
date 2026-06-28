#!/bin/bash
# update_basetime.sh - Calculate basetime and update cfg file
#
# Usage:
#   ./update_basetime.sh tsn       (updates enable_tsn.cfg)
#   ./update_basetime.sh frer      (updates enable_frer.cfg)
#   ./update_basetime.sh mode4     (updates mode4.cfg)
#   ./update_basetime.sh mode5     (updates mode5.cfg)

if [ -z "$1" ]; then
    echo "Usage: $0 <name>"
    echo "  e.g.: $0 tsn    -> updates enable_tsn.cfg"
    echo "  e.g.: $0 frer   -> updates enable_frer.cfg"
    echo "  e.g.: $0 mode4  -> updates mode4.cfg"
    echo "  e.g.: $0 mode5  -> updates mode5.cfg"
    exit 1
fi

NAME="$1"

CFG_DIR="/srv/www/tsn/uart"
TSN_TOOL="/opt/microchip/tsn/microchip-tsn-replace-tsnbasetime"

# Source base addresses from single definition
source "${CFG_DIR}/bases.env"

BASE_ADDR=$TSN_BASE

# Offsets
OFFSET_BASETIME_NSEC="0x070"
OFFSET_BASETIME_SEC_LO="0x074"
OFFSET_BASETIME_SEC_HI="0x078"

# Determine file names based on argument
case "$NAME" in
    mode*)
        CFG_FILE="${CFG_DIR}/${NAME}.cfg"
        JSON_IN="${CFG_DIR}/${NAME}.json"
        ;;
    *)
        CFG_FILE="${CFG_DIR}/enable_${NAME}.cfg"
        JSON_IN="${CFG_DIR}/enable_${NAME}.json"
        ;;
esac

JSON_OUT="/tmp/${NAME}_out.json"

echo "=== Update Basetime (${NAME}) ==="
echo "  CFG file : $CFG_FILE"
echo "  JSON in  : $JSON_IN"
echo "  BASE     : $BASE_ADDR"

# Check cfg file exists
if [ ! -f "$CFG_FILE" ]; then
    echo "ERROR: $CFG_FILE not found"
    exit 1
fi

# Check json input exists
if [ ! -f "$JSON_IN" ]; then
    echo "ERROR: $JSON_IN not found"
    exit 1
fi

# Step 1: Run the TSN basetime tool
echo "Running: $TSN_TOOL"

$TSN_TOOL --ptpfile=/dev/ptp0 --addtimesec=1 --addtimensec=0 \
    --infile=$JSON_IN --outfile=$JSON_OUT

if [ $? -ne 0 ]; then
    echo "ERROR: TSN basetime tool failed"
    exit 1
fi

# Step 2: Extract values from JSON
BASETIME_SEC=$(grep -o '"basetimesec":[^,]*' $JSON_OUT | grep -o '[0-9]*')
BASETIME_NSEC=$(grep -o '"basetimensec":[^,]*' $JSON_OUT | grep -o '[0-9]*')

if [ -z "$BASETIME_SEC" ] || [ -z "$BASETIME_NSEC" ]; then
    echo "ERROR: Could not extract basetime from $JSON_OUT"
    exit 1
fi

echo "  basetimesec  = $BASETIME_SEC"
echo "  basetimensec = $BASETIME_NSEC"

# Step 3: Calculate register values
REG_70=$(printf "0x%08X" $((BASETIME_NSEC & 0xFFFFFFFF)))
REG_74=$(printf "0x%08X" $((BASETIME_SEC & 0xFFFFFFFF)))
REG_78=$(printf "0x%08X" $(((BASETIME_SEC >> 32) & 0xFFFFFFFF)))

# Print with full address for debug
FULL_70=$(printf "0x%08X" $((BASE_ADDR + 0x070)))
FULL_74=$(printf "0x%08X" $((BASE_ADDR + 0x074)))
FULL_78=$(printf "0x%08X" $((BASE_ADDR + 0x078)))

echo "  ${OFFSET_BASETIME_NSEC}    = $REG_70 (basetimensec)      [abs: $FULL_70]"
echo "  ${OFFSET_BASETIME_SEC_LO}    = $REG_74 (basetimesec lo)    [abs: $FULL_74]"
echo "  ${OFFSET_BASETIME_SEC_HI}    = $REG_78 (basetimesec hi)    [abs: $FULL_78]"

# Step 4: Update the .cfg file using offsets
sed -i -E "s|^${OFFSET_BASETIME_NSEC}[[:space:]]+.*|${OFFSET_BASETIME_NSEC}    $REG_70|" "$CFG_FILE"
sed -i -E "s|^${OFFSET_BASETIME_SEC_LO}[[:space:]]+.*|${OFFSET_BASETIME_SEC_LO}    $REG_74|" "$CFG_FILE"
sed -i -E "s|^${OFFSET_BASETIME_SEC_HI}[[:space:]]+.*|${OFFSET_BASETIME_SEC_HI}    $REG_78|" "$CFG_FILE"

echo "  Updated: $CFG_FILE"
echo "=== Done ==="
