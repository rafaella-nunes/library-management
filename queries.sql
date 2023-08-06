CREATE TABLE autores IF NOT EXISTS (
    id INT PRIMARY KEY,
    nome VARCHAR(255),
);

CREATE TABLE livros IF NOT EXISTS (
    id INT PRIMARY KEY,
    titulo VARCHAR(255),
    autorID INT,
    genero VARCHAR(100),
    ano_publicacao INT,
    ISBN VARCHAR(20),
    FOREIGN KEY (autorID) REFERENCES autores(autorID)
);

CREATE TABLE users IF NOT EXISTS (
    id INT PRIMARY KEY,
    nome VARCHAR(255),
    email VARCHAR(255),
    senha VARCHAR(100),
    data_cadastro DATE
);

CREATE TABLE emprestimos IF NOT EXISTS (
    id INT PRIMARY KEY,
    livroID INT,
    userID INT,
    data_emprestimo DATE,
    data_devolucao_programada DATE,
    data_devolucao DATE,
    status VARCHAR(50),
    FOREIGN KEY (livroID) REFERENCES livros(livroID),
    FOREIGN KEY (userID) REFERENCES users(userID)
);

CREATE TABLE reservas IF NOT EXISTS (
    id INT PRIMARY KEY,
    livroID INT,
    userID INT,
    data_reserva DATE,
    data_disponivel DATE,
    FOREIGN KEY (livroID) REFERENCES livros(livroID),
    FOREIGN KEY (userID) REFERENCES users(userID)
);


--Functions


CREATE OR REPLACE FUNCTION calcular_multa(data_devolucao DATE, data_devolucao_programada DATE) 
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE multa DECIMAL(10, 2);
    
    IF data_devolucao > data_devolucao_programada THEN
        SET multa = DATEDIFF(data_devolucao, data_devolucao_programada) * 2.00; -- multa diária R$2.00
    ELSE
        SET multa = 0.00;
    END IF;
    
    RETURN multa;
END;

CREATE OR REPLACE FUNCTION gerar_relatorio_atrasados() RETURNS TABLE
BEGIN
    RETURN (
        SELECT 
            E.id,
            U.nome AS nome_usuario,
            L.titulo AS titulo_livro,
            E.emprestimos.data_emprestimo,
            E.emprestimos.data_devolucao_programada,
            E.emprestimos.data_devolucao,
            E.emprestimos.status
        FROM emprestimos E
        JOIN users U ON E.user_id = U.id
        JOIN livros L ON E.livro_id = L.id
        WHERE E.status = 'Atrasado'
    );
END;

