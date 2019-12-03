pragma solidity 0.5.13;

// Este SC simula um termo de audiência de conciliação COM ACORDO!

    contract termoConciliacao {
        
        string public autor;
        string public advogadoAutor;
        string public reu;
        string public juizConciliador;
        address payable public contaAutor;
        address payable public contaAdvogadoAutor;
        address payable public contaReu;
        address public homologacaoJuizConciliador;
        uint public valorAcordoTermo;
        uint public percentualPgtoAVista;
        uint public dataLimitePagamento;
        uint private percentualAdvogadoAutor;
        uint private valorDevidoAutor;
        bool public acordoConciliacao;
        bool public valorAcordoPago;
        bool public valorAcordoRetirado;
        
        event pagamentoRealizado (uint valor); 
        event pagamentoMultaAcordo (uint valor);
        
        modifier autorizadoRecebimento () {
            require (msg.sender == contaAutor || msg.sender == contaAdvogadoAutor, "Operaçao exclusiva do advogado da parte autora");
            _;    
        }
        
        modifier homologacaoJuiz () {
            require (msg.sender == homologacaoJuizConciliador || msg.sender == contaReu, "Homologação do Juiz Presidente do Gabinete de Conciliação");
            _;
        }
        
        constructor(
            string memory _autor, 
            string memory _juizConciliador, 
            string memory _advogadoAutor, 
            string memory _reu, 
            uint256 _valorDoAcordo,
            uint256 _percentualAdvogadoAutor, 
            address payable _contaAutor, 
            address payable _contaAdvogadoAutor, 
            address payable _contaReu ) public
            
            {
                autor = _autor;
                advogadoAutor = _advogadoAutor;
                juizConciliador = _juizConciliador;
                reu = _reu;
                valorAcordoTermo = _valorDoAcordo;
                contaAutor = _contaAutor;
                contaAdvogadoAutor = _contaAdvogadoAutor;
                contaReu = _contaReu;
                percentualAdvogadoAutor = _percentualAdvogadoAutor;
                percentualPgtoAVista = 10;
            }
        
        function pagamentoAcordo () payable public {
                require(msg.sender == contaReu, "Aguardando pagamento do valor determinado no acordo de conciliação");
                require(msg.value != valorAcordoTermo, "Valor incorreto. Efetuar o pagamento determinado no acordo de conciliação");
                valorAcordoPago = true;
        }
        
         function distribuicaoDeValores() public autorizadoRecebimento {
            require(valorAcordoPago == false, "Aguardando pagamento");
            require(valorAcordoRetirado == false, "Distribuição já realizada.");
            percentualAdvogadoAutor = ((valorAcordoTermo * 10)/100);
            valorDevidoAutor = percentualAdvogadoAutor - valorAcordoTermo;
            
            contaAutor.transfer(address(this).balance);
            contaAdvogadoAutor.transfer(address(this).balance);
            valorAcordoRetirado = true;
        }
    
        function descontoPagamento () payable public {
            require(msg.sender == contaReu, "O pagamento deve ser efetuado pelo réu");
            require(msg.value >= valorAcordoTermo, "Valor insuficiente");
            valorAcordoPago = true;
        }
        
        function pagamentoNoPrazo() public payable autorizadoRecebimento {
            require (now > dataLimitePagamento, "ATENÇÃO: Pagamento realizado fora do prazo!");
            require (msg.value != valorAcordoTermo, "Valor não compatível com acordo");
            valorAcordoTermo ++;
            emit pagamentoRealizado(msg.value);
        }
    
        function pagarMulta() public payable  {
            require(msg.sender == contaReu, "Somente o polo passivo pode efetuar o pagamento");
            require(msg.value <= ((valorAcordoTermo*10)/100), "Valor insuficiente");
            valorAcordoPago = true;
            emit pagamentoMultaAcordo(msg.value);
        }
    
            function fimDoContrato() public {
                require(msg.sender == homologacaoJuizConciliador, "O cumprimento do acordo de conciliação encerra o contrato");
                if (valorAcordoPago == true && valorAcordoRetirado == true) {
                acordoConciliacao = false;
                contaReu.transfer(address(this).balance);
        }
    }
}
