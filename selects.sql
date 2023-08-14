--Verificar acervo
SELECT * FROM livros;

--Verificar usuarios que estão com livros emprestados e qual livro
SELECT
    U.nome AS NomeUsuario,
    L.titulo AS TituloLivro
FROM emprestimos E
JOIN usuarios U ON E.userID = U.id
JOIN livros L ON E.livroID = L.id
WHERE E.status = 'Emprestado';

--View livros emprestados
SELECT * FROM livros_emprestados;

--Devolver livro
UPDATE emprestimos
SET status = 'Devolvido'
WHERE id = 3;

--Checar se a notificacao chegou
SELECT * FROM notificacoes