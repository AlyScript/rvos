define walk_pt
    set $vaddr = $arg0
    set $root_idx = ($vaddr >> 30) & 0x1ff
    set $l2_idx = ($vaddr >> 21) & 0x1ff
    set $l3_idx = ($vaddr >> 12) & 0x1ff

    printf "--- PAGE TABLE WALK FOR %p ---\n", $vaddr

    set $pte1 = __root_pte[$root_idx]
    printf "L1 (Root) PTE [%d]: %p\n", $root_idx, $pte1
    if (!($pte1 & 1))
        printf "  -> FAULT: Root entry is Invalid!\n"
    end
    if (($pte1 & 0x10))
        printf "  -> WARNING: User bit (U) is SET in Root!\n"
    end
    if (($pte1 & (1 << 7)))
        printf "  -> WARNING: Accessed bit (A) is SET in Root!\n"
    end
    if (($pte1 & (1 << 6)))
        printf "  -> WARNING: Dirty bit (D) is SET in Root!\n"
    end

    set $l2_phys = (($pte1 >> 10) << 12)
    set $pte2 = ((uint64_t*)$l2_phys)[$l2_idx]
    printf "L2 PTE [%d] at %p: %p\n", $l2_idx, $l2_phys, $pte2
    if (!($pte2 & 1))
        printf "  -> FAULT: Level 2 entry is Invalid!\n"
    end
    if (($pte2 & 0x10))
        printf "  -> WARNING: User bit (U) is SET in Level 2!\n"
    end
    if (($pte1 & (1 << 7)))
        printf "  -> WARNING: Accessed bit (A) is SET in Level 2!\n"
    end
    if (($pte1 & (1 << 6)))
        printf "  -> WARNING: Dirty bit (D) is SET in Level 2!\n"
    end

    set $l3_phys = (($pte2 >> 10) << 12)
    set $pte3 = ((uint64_t*)$l3_phys)[$l3_idx]
    printf "L3 (Leaf) PTE [%d] at %p: %p\n", $l3_idx, $l3_phys, $pte3
    if (!($pte3 & 1))
        printf "  -> FAULT: Leaf entry is Invalid!\n"
    end
    if (!($pte3 & 0x8))
        printf "  -> FAULT: Executable bit (X) is MISSING in Leaf!\n"
    end
end

document walk_pt
  Perform a 3-level page table walk for a given virtual address.
  Usage: walk_pt <virtual_address>
end
