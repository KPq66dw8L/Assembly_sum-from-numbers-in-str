section .data
    sum: db 0
    buffer: db 0 ; buffer for output
    mystr: db '',0
    eol: db 10

section .text
    global _start

_start:

    xor eax, eax              ; vide le registre
    xor ebx, ebx              ; vide le registre
    xor ecx, ecx              ; vide le registre
    xor edx, edx              ; vide le registre

    loop:                     ; loop principale
        call get_input        ; appelle la fonction
        xor eax, eax          ; vide le registre
        xor ebx, ebx          ; vide le registre
        xor edx, edx          ; vide le registre
        xor ecx, ecx          ; vide le registre
        mov al, [mystr]       ; met le string lu dans al 
        test:                 ; label pour retourner ici plus tard
        cmp al, 57            ; check si le caractere est un nombre, etape 1: decimal ASCII valeur <= 57
        jle number_step2      ; lower equal jump vers etape 2 de verification de nombre
        jmp loop              ; retourne au debut de la boucle

    get_input:
        ; On va lire caractere par caractere
        mov eax, 3            ; sys_read
        mov ebx, 0            ; stdin
        mov edx, 1            ; taille de la chaine forcement 1
        mov ecx, mystr        ; adresse de la chaine
        int 80h               ; syscall 
        
        cmp byte [mystr], 10  ; check si fin du string/new line
        je pre_init_affichage ; jump si egale

        cmp byte [mystr], 57  ; check si le caractere est un nombre, etape 1: decimal ASCII valeur <= 57
        jle convert_number_1  ; si oui, on va le convertir en lettre majuscule avant d'afficher
        ; Affichge de la chaine
        mov eax, 4            ; sys_read
        mov ebx, 1            ; stdin
        mov edx, 1            ; taille de la chainem forcement 1
        mov ecx, mystr        ; adresse de la chaine
        int 80h               ; syscall 
        ret                   ; retourne au niveau du call dans la loop
    
    convert_number_1:
        cmp al, 48            ; etape 2 de verification du caractere, si sup a 48 alors c'est bien un nombre
        jge convert_number_2  ; on saute si sup egale
    
    convert_number_2:
        xor eax, eax          ; vide le registre
        mov eax, [mystr]      ; deplace valeur du caractere dans eax
        add eax, 17           ; ajoute 17 a cette valeur pour le transformer en lettre majuscule
        mov [mystr], eax      ; on remet dans la variable
        ; On affiche la lettre maj
        mov eax, 4            ; sys_read
        mov ebx, 1            ; stdin
        mov edx, 1            ; taille de la chainem forcement 1
        mov ecx, mystr        ; adresse de la chaine
        int 80h               ; int logicielle
        xor eax, eax          ; vide le registre
        mov eax, [mystr]      ; deplace valeur du caractere dans eax
        sub eax, 17           ; soustrait 17 pour revenir a la valeur initiale 
        mov [mystr], eax      ; et on remet cette valeur dans la variable

    number_step2:
        cmp al, 48            ; check si caractere est un nombre, step 2: decimal ASCII valeur >= 48
        jge number_detected   ; on saute si sup egale
        jmp loop              ; on retourne a la boucle
    
    number_detected:
        mov bl, al            ; deplace valeur de al dans bl
        sub bl, '0'           ; convertie en nombre
        add [sum], bl         ; ajoute la valeur a la somme
        jmp loop              ; retourne a la boucle

    pre_init_affichage:
        ; New line apres affichage avec les chiffres convertis en lettre maj
        mov edx, 1            ; taille du buffer
        mov ecx, eol          ; adresse du buffer
        mov ebx, 1            ; stdout
        mov eax, 4            ; sys_write
        int 80h               ; syscall
        ; jump implicite sur init_affichage

    init_affichage:
        xor esi, esi        ; vide le registre, reset le compteur, on va l'utiliser pour compter le nombre de chiffres de la somme
        xor eax, eax        ; vide le registre
        mov al, [sum]       ; charge la somme dans al
        mov ecx, 10         ; base 10, on veut recuperer les chiffres un par un, on recupere l'unite puis la dizaine etc...
    affichage:
        cmp eax,0           ; check si eax vaut 0
        je exit             ; si eax vaut 0, jump a exit
        xor edx, edx        ; vide le registre, on va y stocker le reste de la division
        div ecx             ; divise eax par 10 et stocke le reste dans edx
        push edx            ; empile le reste, on va l'utiliser pour afficher le chiffre
        inc esi             ; incrémente le compteur, on utilise esi pour compter le nombre de chiffres de la somme
        jmp affichage       ; loop vers affichage

    exit:
        cmp esi, 0          ; check si esi vaut 0
        je quit             ; si oui, jump a quit, on a fini d'afficher la somme
        pop edx             ; dépile le reste de la division faite précédemment, on va l'utiliser pour afficher le chiffre
        mov [buffer], dl    ; stocke le reste dans le buffer, on va l'afficher
        add byte [buffer], 48 ; converti en ascii, on ajoute 48 car 48 est le code ascii de 0
        push esi            ; empile le compteur
        mov edx, 1          ; taille du buffer
        mov ecx, buffer     ; adresse du buffer
        mov ebx, 1          ; stdout
        mov eax, 4          ; sys_write
        int 80h             ; syscall
        pop esi             ; dépile le compteur
        dec esi             ; décrémente le compteur, on va afficher le prochain chiffre
        
        jmp exit            ; loop sur exit, on affiche le prochain chiffre
    quit:
    ; New line apres sum
    mov edx, 1              ; taille du buffer
    mov ecx, eol            ; adresse du buffer
    mov ebx, 1              ; stdout
    mov eax, 4              ; sys_write
    int 80h                 ; syscall
    ; Quitte le programme
    mov eax, 1              ; sys_exit
    mov ebx, 0              ; exit code
    int 80h                 ; syscall
