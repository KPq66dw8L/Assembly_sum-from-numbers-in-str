section .data
    sum: db 0
    buffer: db 0 ; buffer for output
    ; mystr: db 'd4adjskhfbasdm3a4a2iad1',0
    mystr: db '',0
    eol: db 10

section .text
    global _start

_start:

    xor eax, eax         ; vide le registre
    xor ebx, ebx         ; vide le registre
    xor ecx, ecx         ; vide le registre
    xor edx, edx         ; vide le registre
    xor esi, esi
    ; mov al, [mystr+esi]

    loop:
        call get_input
        xor eax, eax
        xor ebx, ebx
        xor edx, edx
        xor ecx, ecx
        mov al, [mystr]
        
        cmp al, 57          ; check if character is a number, step 1: decimal ASCII value <= 57
        jle number_step2        
        mov al, [mystr] ; charge le prochain char de la chaine dans al, l'indice esi est utilisé pour parcourir la chaine

        jmp loop

    get_input:
        ; On lit charactere par charactere
        mov eax, 3           ; sys_read
        mov ebx, 0           ; stdin
        mov edx, 1           ; taille de la chainem forcement 1
        mov ecx, mystr       ; adresse de la chaine
        int 80h              ; syscall 
        cmp byte [mystr], 10           ; check for end of string
        je init_affichage
        ret                  ; return to the loop where we where

    number_step2:
        cmp al, 48          ; check if character is a number, step 2: decimal ASCII value >= 48
        jge number_detected
        jmp loop
    
    number_detected:
        mov bl, al 
        sub bl, '0'         ; convert to number
        add [sum], bl       ; add to sum
        mov al, [mystr] ; charge le prochain char de la chaine dans al, l'indice esi est utilisé pour parcourir la chaine
        jmp loop 

    init_affichage:
        xor esi, esi        ; vide le registre, reset le compteur, on va l'utiliser pour compter le nombre de chiffres de la somme
        xor eax, eax        ; vide le registre
        mov al, [sum]       ; charge la somme dans al
        mov ecx, 10         ; base 10, on veut recuperer les chiffres un par un, on recupere l'unite puis la dizaine etc...
    affichage:
        cmp eax,0           ; check if eax is 0
        je exit             ; if eax is 0, jump to exit
        xor edx, edx        ; vide le registre, on va y stocker le reste de la division
        div ecx             ; divise eax par 10 et stocke le reste dans edx
        push edx            ; empile le reste, on va l'utiliser pour afficher le chiffre
        inc esi             ; incrémente le compteur, on utilise esi pour compter le nombre de chiffres de la somme
        jmp affichage       ; loop back to affichage

    exit:
        cmp esi, 0          ; check if esi is 0
        je quit             ; if esi is 0, jump to quit, on a fini d'afficher la somme
        pop edx             ; dépile le reste de la division faite précédemment, on va l'utiliser pour afficher le chiffre
        mov [buffer], dl    ; stocke le reste dans le buffer, on va l'afficher
        add byte [buffer], 48 ; convert to ascii, on ajoute 48 car 48 est le code ascii de 0
        push esi            ; empile le compteur
        mov edx, 1          ; taille du buffer
        mov ecx, buffer     ; adresse du buffer
        mov ebx, 1          ; stdout
        mov eax, 4          ; sys_write
        int 80h             ; syscall
        ; New line to get a clean result
        mov edx, 1          ; taille du buffer
        mov ecx, eol     ; adresse du buffer
        mov ebx, 1          ; stdout
        mov eax, 4          ; sys_write
        int 80h             ; syscall
        pop esi             ; dépile le compteur
        dec esi             ; décrémente le compteur, on va afficher le prochain chiffre
        jmp exit            ; loop back to exit, on affiche le prochain chiffre
    quit:
    ; Quitte le programme
    mov eax, 1              ; sys_exit
    mov ebx, 0              ; exit code
    int 80h                 ; syscall