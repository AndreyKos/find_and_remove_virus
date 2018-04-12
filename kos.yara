rule MINER
{
        strings:
                $a = {3C 3F 70 68  70 20 24 7B  22 5C 78 ??  ?? 5C 78 ??  ?? 5C 78 ??  ?? ?? 5C 78  ?? ?? 5C 78  ?? ?? 5C 78 ?? ?? 22 7D  5B 27 ?? ??  ?? ?? ?? ??  27 5D 20 3D  20 22 5C 78  ??}
        condition:
                $a
}
rule NEW
{
        strings:
                $a = {3C 3F 70 68  70 0A 0A 09  24 ?? ?? ??  ?? ?? 20 3D  20 0A 09 09  27}
        condition:
                $a
}
rule LONG_SPASE
{
        strings:
                $a = {3c3f 7068 7020  2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020 2020}
        condition:
                $a
}

rule CHR
{
        strings:
                $a = {2e 63 68 72 28 ?? ?? ?? 5e ?? ?? ?? 29 2e 63 68 72 28 } /* .chr(345^343).chr( */
                $b = {2e 63 68 72 28 ?? ?? 5e ?? ??  29 2e 63 68 72 28 } /* .chr(34^34).chr( */
        condition:
                $a or $b
}

rule GLOBALS
{
        strings:
                $hex1 = { 2e 24 47 4c 4f 42 41 4c 53 5b 27 ?? ?? ?? ?? ?? 27 5d 5b ?? ?? 5d }
        condition:
                $hex1
}
rule XXX
{
        strings:
                $a = { 24 7b 22 5c 78 [15-32] 22 7d 5b 22 5c 78 [15-32] 22 5d }
        condition:
                $a
}
rule PASS
{
        strings:
                $a = { 3b 65 76 61 6c 28 }
                $b = { 24 50 41 53 53 3d 22 }
                $c = { 66 75 6e 63 74 69 6f 6e }
        condition:
                $a and $b and $c
}

rule URLDECODE
{
        strings:
                $a = { 3d 75 72 6c 64 65 63 6f 64 65 28 22 25 }
        condition:
                $a
}

rule PREG_REPLACE
{
        strings:
                $a = { 40 70 72 65 67 5f 72 65 70 6c 61 63 65 } /* @preg_replace */
                $b = { 40 65 76 61 6c 28 24 5f 50 4f 53 54 } /* @eval($_POST */
        condition:
                $a or $b
}
