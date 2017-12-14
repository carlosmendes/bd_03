require "pg"

describe 'SQL' do
  let(:db) { PG::connect(dbname: 'postgres') }

  describe 'Field Types' do
    it 'EAN > 13' do
      expect(db.exec("select character_maximum_length as ean_letters from information_schema.columns where table_name = 'produto' AND column_name = 'ean';").first["ean_letters"].to_i).to be >= 13
    end
    it 'Unidades cannot be varchar' do
      expect(db.exec("select udt_name as type from information_schema.columns where table_name = 'reposicao' AND column_name = 'unidades';").first["type"]).not_to eq 'varchar'
    end
    it 'Instante not timestamp' do
      expect(db.exec("select udt_name as type from information_schema.columns where table_name = 'reposicao' AND column_name = 'instante';").first["type"]).to eq 'timestamp'
    end
    it 'Nome Fornecedor como not null' do
      expect(db.exec("select is_nullable as nullable from information_schema.columns where table_name = 'fornecedor' AND column_name = 'nome';").first["nullable"]).to eq 'NO'
    end
  end

  describe 'RIs' do
    it 'RI-RE1 : nome tem de existir em categoria_simples ou em super_categoria' do
      expect(db.exec("SELECT count(*) FROM categoria
                      WHERE nome not IN (SELECT nome from categoria_simples) AND nome not IN (SELECT nome from super_categoria)").first["count"].to_i).to eq 0
    end
    it 'RI-RE2 : nome só pode existir em categoria_simples ou em super_categoria' do
      expect(db.exec("SELECT count(*) FROM categoria_simples NATURAL JOIN super_categoria").first["count"].to_i).to eq 0
    end
    it 'RI-RE3 : super_categoria tem de existir em constituida' do
      expect(db.exec("SELECT count(*) FROM super_categoria WHERE nome not in (select super_categoria FROM constituida)").first["count"].to_i).to eq 0
    end
    it 'RI-RA2 : super_categoria != categoria' do
      expect(db.exec("SELECT count(*) FROM constituida WHERE super_categoria = categoria").first["count"].to_i).to eq 0
    end

    it 'RI-RE3 : todo o EAN tem de existir em fornece_sec' do
      expect(db.exec("SELECT count(*) FROM produto WHERE ean not in (select ean from fornece_sec)").first["count"].to_i).to eq 0
    end

    it 'RI-EA4 : fornecedor primario não pode ser secundário para o mesmo ean' do
      # puts db.exec("SELECT * FROM produto NATURAL JOIN fornece_sec WHERE fornece_sec.nif = produto.forn_primario").first
      expect(db.exec("SELECT count(*) FROM produto NATURAL JOIN fornece_sec WHERE fornece_sec.nif = produto.forn_primario").first["count"].to_i).to eq 0
    end
  end

end
