#Creator: Gabriella Quattrone
.global matMult
.equ ws, 4

.text
/*int** matMult(int **a,int num_rows_a, int num_cols_a, int** b, int num_rows_b, int num_cols_b){
	int i, j, k;
	int** C = (int**) malloc( num_rows_a * sizeof(int*));
	for(i = 0; i < num_rows_a; ++i){
		C[i] = (int*)malloc( num_cols_b * sizeof(int));
		for(j = 0; j < num_cols_b; ++j){
		    C[i][j] = 0;
		    for(k = 0; k < num_cols_a; ++k){
			    C[i][j] = C[i][j] + (a[i][k] * b[k][j]);
		    }
		}
	}
	return C;
}*/

matMult:
	prologue:
		push %ebp
		movl %esp, %ebp
		subl $5*ws, %esp
		push %ebx
		push %esi
		push %edi

		#stack after prologue
		#     num_cols_b
		#     num_rows_b
		#     b
		#     num_cols_a
		#     num_rows_a
		#     a
		#     ret address
		#ebp: old ebp
		#     i
		#     j
		#	  k
		#	  C
		.equ a,        		(2*ws) #(%ebp)
		.equ num_rows_a,        (3*ws) #(%ebp)
		.equ num_cols_a, 	(4*ws) #(%ebp)
		.equ b, 	  	(5*ws) #(%ebp)
		.equ num_rows_b,	(6*ws) #(%ebp)
		.equ num_cols_b,	(7*ws) #(%ebp)
		.equ i,        		(-1*ws) #%ebp
		.equ j,        		(-2*ws) #(%ebp)
		.equ k,			(-3*ws) #(%ebp)
		.equ C,        		(-4*ws) #(%ebp)
		.equ sum,               (-5*ws) #(%ebp)

		#int** C = (int**) malloc(num_rows_a * sizeof(int*));
		movl num_rows_a(%ebp), %eax #eax = num_rows
		shll $2, %eax  #eax = num_rows * sizeof(int*)) 
		push %eax #place malloc's argument onto the stack
		call malloc

		addl $1*ws, %esp #clear malloc's arguement 
		#eax = (int**) malloc(num_rows * sizeof(int*));
		movl %eax, C(%ebp) 
		
		movl $0, %eax #i = 0
		for1:
			#for(i = 0; i < num_rows_a; ++i){
			cmpl num_rows_a(%ebp), %eax
			jge end_for1

			#C[i] = (int*)malloc( num_cols_b * sizeof(int));
			movl num_cols_b(%ebp), %edx #edx = num_cols
			shll $2, %edx # edx = num_cols * sizeof(int)
			push %edx #set arguement for malloc
			movl %eax, i(%ebp) #save i 
			call malloc
			addl $1*ws, %esp #clear arguement for malloc
			#eax = (int*)malloc( num_cols * sizeof(int));
			movl %eax, %edx  #edx = (int*)malloc( num_cols * sizeof(int));
			movl i(%ebp), %eax #restore i
			movl C(%ebp), %ecx #ecx = C
			movl %edx, (%ecx, %eax, ws) #C[i] = edx 
			#movl %edx, C(%ebp, %eax, ws) == (&C)[i] = %edx

			movl $0, %ecx #j = 0
			
			for2:
				movl $0, sum(%ebp)
				#for(j = 0; j < num_cols_b; ++j){
				cmpl num_cols_b(%ebp), %ecx
				jge end_for2

				movl C(%ebp), %edi #edi = c
				movl (%edi, %eax, ws), %edi #edi = c[i]
				movl (%edi, %ecx, ws), %edi #edi = c[i][j]
				movl $0, %edi
				#C[i][j] = 0

				movl $0, %esi #k = 0
				for3:
					#for(k = 0; k < num_cols_a; ++k){
					cmpl num_cols_a(%ebp), %esi
					jge end_for3

					#C[i][j] = C[i][j] + (a[i][k] * b[k][j]);
					#ebx will be a[i][k]
					movl a(%ebp), %ebx #ebx = A
					movl (%ebx, %eax, ws), %ebx #ebx = a[i]
					movl (%ebx, %esi, ws), %ebx #ebx = a[i][k]
					
					#ebx will be a[i][k] * b[k][j]
					#edi will be b[i][j]
					movl b(%ebp), %edi #edi = b
					movl (%edi, %esi, ws), %edi #edi = b[k]
					movl (%edi, %ecx, ws), %edi #edi = B[k][j]
						
					movl %eax, i(%ebp) #save i
					movl %ecx, j(%ebp) #save j
					movl %esi, k(%ebp) #save k
					movl %edi, %eax #eax = b[k][j]
					mull %ebx
					movl %eax, %ebx #ebx = a[i][k] * b[k][j]
					movl i(%ebp), %eax #restore eax = i
					movl j(%ebp), %ecx
					movl k(%ebp), %esi
					#C[i][j] = C[i][j] + (a[i][k] * b[k][j]);
					
					movl C(%ebp), %edi #edi = b
					movl (%edi, %eax, ws), %edi #edi = c[i]
					addl %ebx, sum(%ebp)
					movl sum(%ebp), %ebx
					movl %ebx, (%edi, %ecx, ws)


					incl %esi #++k
					jmp for3
				
				end_for3:
				incl %ecx #++j
				jmp for2

			end_for2:
			incl %eax
			jmp for1

		end_for1:
		#return C
		movl C(%ebp), %eax

		epilogue:
			pop %edi
			pop %esi
			pop %ebx
			movl %ebp, %esp
			pop %ebp
			ret



