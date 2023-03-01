

section .data
    sum: db 0
    buffer: db 0 ; buffer for output
    mydig: db '0123456789',0 ; 0 signifie la fin de la chaine
    mystr: db '4312',0

section .text
    global _start

_start:
    xor esi, esi            ; vide le registre, compteur 1
    xor edi, edi            ; vide le registre, compteur 2
    mov al, [mystr+esi]     ; charge le 1er char de la chaine dans al, l'indice esi est utilisé pour parcourir la chaine

    loop:                   ; compares each digit with byte in al
        mov bl, [mydig+edi] ; charge le 1er char de la chaine dans bl, l'indice edi est utilisé pour parcourir la chaine
        cmp al,0            ; check for end of string
        je init_affichage   ; if end of string, jump to init_affichage
        cmp bl,al           ; compare al to each digit
        je number_detected  ; if equal to one of the digits, we have a number
        inc edi             ; increment the index of the reference string
        jmp loop            ; loop back to the beginning
    number_detected:
        sub bl, '0'         ; convert to number
        add [sum], bl       ; add to sum
        inc esi             ; increment the index of the string we are checking
        mov al, [mystr+esi] ; charge le prochain char de la chaine dans al, l'indice esi est utilisé pour parcourir la chaine
        xor edi, edi        ; on reset le compteur de la chaine de refence des chiffres
        jmp loop            ; loop back to the beginning

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
        pop esi             ; dépile le compteur
        dec esi             ; décrémente le compteur, on va afficher le prochain chiffre
        jmp exit            ; loop back to exit, on affiche le prochain chiffre
    quit:
    ; Quitte le programme
    mov eax, 1              ; sys_exit
    mov ebx, 0              ; exit code
    int 80h                 ; syscall