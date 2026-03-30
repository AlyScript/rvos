#include <usr_lib.h>
#include <syscalls.h>

int strcmp(const char *s1, const char *s2);
int starts_with(const char *str, const char *prefix);
int atoi(const char *str);
void gets(char *buf, int max);

/* The Shell Main Loop */
__attribute__((section(".text.entry")))
void _ustart(void) {
    char input[64];
    int shell_pid = (int)syscall(SYS_GETPID, 0, 0, 0);

    printf("\n==================================\n");
    printf("   Welcome to AdamOS (PID: %d)\n", shell_pid);
    printf("==================================\n");

    while (1) {
        printf("AdamOS> ");
        gets(input, 64);

        if (input[0] == '\0') {
            continue; /* Just hit Enter, do nothing */
        }

        if (strcmp(input, "help") == 0) {
            printf("Commands:\n");
            printf("  spawn    - Launch a new dummy process in the background\n");
            printf("  kill <n> - Terminate process with PID <n>\n");
            printf("  help     - Show this message\n");
        } 
        else if (strcmp(input, "spawn") == 0) {
            int new_pid = (int)syscall(SYS_SPAWN, 0, 0, 0);
            if (new_pid > 0) {
                printf("[Shell] Spawned background process with PID %d\n", new_pid);
            } else {
                printf("[Shell] Error: Max processes reached.\n");
            }
        } 
        else if (starts_with(input, "kill ")) {
            /* Parse the number right after "kill " */
            int target = atoi(&input[5]); 
            if (target == shell_pid) {
                printf("[Shell] Refusing to kill myself!\n");
                continue;
            }
            
            int res = (int)syscall(SYS_KILL, target, 0, 0);
            if (res == 0) {
                printf("[Shell] Successfully sent kill signal to PID %d\n", target);
            } else {
                printf("[Shell] Failed to kill PID %d. Does it exist?\n", target);
            }
        } 
        else {
            printf("Unknown command: %s\n", input);
        }
    }
}

int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(const unsigned char*)s1 - *(const unsigned char*)s2;
}

int starts_with(const char *str, const char *prefix) {
    while (*prefix) {
        if (*prefix++ != *str++) return 0;
    }
    return 1;
}

int atoi(const char *str) {
    int res = 0;
    while (*str >= '0' && *str <= '9') {
        res = res * 10 + (*str - '0');
        str++;
    }
    return res;
}

void gets(char *buf, int max) {
    int i = 0;
    while (i < max - 1) {
        char c = getchar();
        
        /* Enter key (Carriage Return or Line Feed) */
        if (c == '\r' || c == '\n') {
            putchar('\n');
            break;
        } 
        /* Backspace (ASCII 8 or 127) */
        else if (c == '\b' || c == 127) {
            if (i > 0) {
                i--;
                /* Move cursor back, print space to erase, move back again */
                printf("\b \b"); 
            }
        } 
        /* Normal characters */
        else {
            buf[i++] = c;
            putchar(c); /* Echo the key back so you can see what you type */
        }
    }
    buf[i] = '\0';
}

