INSERT INTO autores (id, nome)
VALUES
    (1, 'J.K. Rowling'),
    (2, 'George Orwell'),
    (3, 'Donna Tartt'),
    (4, 'Taylor Jenkins Reid'),
    (5, 'Sally Rooney');

INSERT INTO livros (id, titulo, autorID, genero, ano_publicacao, ISBN)
VALUES
    (1, 'Harry Potter e a Pedra Filosofal', 1, 'Fantasia', 1997, '9788532507208'),
    (2, '1984', 2, 'Ficção Científica', 1949, '9788501016463'),
    (3, 'A História Secreta', 3, 'Thriller', 1992, '9781400031702'),
    (4, 'Os Sete Maridos de Evelyn Hugo', 4, 'Romance', 2017, '9788584391325'),
    (5, 'Pessoas Normais', 5, 'Ficção', 2018, '9781984822178'),
    (6, 'Belo Mundo, Onde Você Está?', 5, 'Ficção', 2021, '9780571365449');

-- Inserir alguns usuários de exemplo
INSERT INTO usuarios (id, nome, email, senha, data_cadastro)
VALUES
    (1, 'João Silva', 'joao@bol.com', 'senha123', '2023-08-14'),
    (2, 'Maria Souza', 'maria@gmail.com', 'abc456', '2023-08-14'),
    (3, 'Pedro Santos', 'pedro@hotmail.com', 'p@ssw0rd', '2023-08-14'),
    (4, 'Ana Oliveira', 'ana@outlook.com', '123qwe', '2023-08-14');

-- Inserir alguns empréstimos de exemplo
INSERT INTO emprestimos (id, livroID, userID, data_emprestimo, data_devolucao_programada, data_devolucao, status)
VALUES
    (1, 1, 2, '2023-08-14', '2023-08-20', NULL, 'Emprestado'),
    (2, 3, 1, '2023-08-15', '2023-08-30', NULL, 'Emprestado'),
    (3, 2, 4, '2023-08-16', '2023-08-25', NULL, 'Emprestado'),
    (4, 4, 3, '2023-08-17', '2023-08-27', NULL, 'Emprestado');

-- Inserir algumas reservas de exemplo
INSERT INTO reservas (id, livroID, userID, data_reserva, data_disponivel)
VALUES
    (1, 1, 3, '2023-08-14', '2023-08-20'),
    (2, 2, 1, '2023-08-15', '2023-08-25'),
    (3, 3, 4, '2023-08-16', '2023-08-30'),
    (4, 4, 2, '2023-08-17', '2023-08-27');
