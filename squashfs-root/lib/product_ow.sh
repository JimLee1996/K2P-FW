. /lib/functions.sh

PA_MD5_MATCH=4ae71336e44bf9bf79d2752e234818a5

wireless_calibrated() {
    local __pa_part=$(find_mtd_part Factory)
    local __pa_md5=$(dd if=$__pa_part count=16 bs=1 skip=512 2>/dev/null | md5sum | awk '{print $1}')
    [[ ! $__pa_md5 = $PA_MD5_MATCH ]]
}
