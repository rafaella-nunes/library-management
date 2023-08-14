-- Tabelas
CREATE TABLE IF NOT EXISTS autores (
    id INT PRIMARY KEY,
    nome VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS livros (
    id INT PRIMARY KEY,
    titulo VARCHAR(255),
    autorID INT,
    genero VARCHAR(100),
    ano_publicacao INT,
    ISBN VARCHAR(20),
    FOREIGN KEY (autorID) REFERENCES autores(id)
);

CREATE TABLE IF NOT EXISTS usuarios (
    id INT PRIMARY KEY,
    nome VARCHAR(255),
    email VARCHAR(255),
    senha VARCHAR(100),
    data_cadastro DATE
);

CREATE TABLE IF NOT EXISTS emprestimos (
    id INT PRIMARY KEY,
    livroID INT,
    userID INT,
    data_emprestimo DATE,
    data_devolucao_programada DATE,
    data_devolucao DATE,
    status VARCHAR(50),
    FOREIGN KEY (livroID) REFERENCES livros(id),
    FOREIGN KEY (userID) REFERENCES usuarios(id)
);

CREATE TABLE IF NOT EXISTS reservas (
    id INT PRIMARY KEY,
    livroID INT,
    userID INT,
    data_reserva DATE,
    data_disponivel DATE,
    FOREIGN KEY (livroID) REFERENCES livros(id),
    FOREIGN KEY (userID) REFERENCES usuarios(id)
);

CREATE TABLE IF NOT EXISTS notificacoes (
    notificacaoID SERIAL,
    userID INT,
    mensagem TEXT,
    data_envio DATE,
    FOREIGN KEY (userID) REFERENCES usuarios(id)
);

-- Função verificar_disponibilidade
CREATE OR REPLACE FUNCTION verificar_disponibilidade(livroID INT) 
RETURNS BOOLEAN AS $$
DECLARE 
    disponivel BOOLEAN;
    cnt INTEGER;
BEGIN
    SELECT COUNT(*) INTO cnt
    FROM emprestimos AS E
    WHERE E.livroID = livroID AND E.status = 'Emprestado';
    
    disponivel := NOT cnt > 0;
    
    RETURN disponivel;
END;
$$ 
LANGUAGE plpgsql;

-- Função att_espera
CREATE OR REPLACE FUNCTION att_espera()
RETURNS TRIGGER AS $$
DECLARE 
    livro_ID INT;
    user_ID INT;
BEGIN
    IF NEW.status = 'Devolvido' THEN
        livro_ID := NEW.livroID;
        
        SELECT userID INTO user_ID
        FROM reservas
        WHERE livroID = livro_ID
        ORDER BY data_reserva
        LIMIT 1;
        
        IF user_ID IS NOT NULL THEN
            -- Enviar notificação para o próximo usuário
            INSERT INTO notificacoes (userID, mensagem, data_envio) VALUES (user_ID, 'O livro que você reservou está disponível.', NOW());
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Gatilho att_lista_espera
CREATE TRIGGER att_lista_espera
AFTER UPDATE ON emprestimos
FOR EACH ROW
EXECUTE FUNCTION att_espera();

-- Visão livros_emprestados
CREATE OR REPLACE VIEW livros_emprestados AS
SELECT
    E.id,
    L.titulo AS titulo_livro,
    A.nome AS nome_autor,
    U.nome AS nome_usuario,
    E.data_emprestimo,
    E.data_devolucao_programada,
    E.status
FROM emprestimos E
JOIN livros L ON E.livroID = L.id
JOIN autores A ON L.autorID = A.id
JOIN usuarios U ON E.userID = U.id
WHERE E.status = 'Emprestado';
