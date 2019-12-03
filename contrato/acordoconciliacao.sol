pragma solidity 0.5.13;

// Este SC simula um termo de audiência de conciliação COM ACORDO

    contract AcordoConciliacao {
        
        string public autor;
        string public advogadoAutor;
        string public reu;
        string public juizConciliador;
        
        address payable public contaAutor;
        address payable public contaAdvogadoAutor;
        address payable public contaReu;
        address public homologacaoJuizConciliador;
        
        uint public valorAcordo;
        uint public percentualPgtoAVista;
        uint private percentualAdvogadoAutor;
        uint private valorDevidoAutor;

        bool public acordoConciliacao;
        bool public valorAcordoPago;
        bool public valorAcordoRetirado;
        
        event pagamentoRealizado (uint valor);
        
        modifier autorizadoRecebimento () {
            require (msg.sender == autor || msg.sender == advogadoAutor, "Operaçao exclusiva do advogado da parte autora");
            _;    
        }
        
        modifier homologacaoJuiz () {
            require (msg.sender == juizConciliador || msg.sender == reu, "Homologação do Juiz Presidente do Gabinete de Conciliação");
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
            address payable _contaReu, 
            address _homologacaoJuizConciliador) public
            
            {
                autor = _autor;
                advogadoAutor = msg.sender;
                juizConciliador = _juizConciliador;
                reu = _reu;
                valorAcordo = _valorDoAcordo;
                contaAutor = _contaAutor;
                contaAdvogadoAutor = _contaAdvogadoAutor;
                contaReu = _contaReu;
                percentualAdvogadoAutor = _percentualAdvogadoAutor;
                percentualPgtoAVista = 10;
            }
        
        function pagamentoAcordo () payable public {
                require(msg.sender == contaReu, "Aguardando pagamento do valor determinado no acordo de conciliação");
                require(msg.value != valorAcordo, "Valor incorreto. Efetuar o pagamento determinado no acordo de conciliação");
                seguroAcordoPago = true;
        
        }
        
    //    function pagamentoParcelado () public payable homologacaoJuiz {
    //        require (now <= dataVencimentoParcela, "Aguardando pagamento da parcela");
    //        require (msg.value == valorAcordo, "Valor diverso do indicado no acordo");
    //        pago = true;
    //        emit pagamentoRealizado(msg.value);
    //    }
        
         function distribuicaoDeValores() public autorizadoRecebimento {
            require(valorAcordoPago == false, "Aguardando pagamento");
            require(valorAcordoRetirado == false, "Distribuição já realizada.");
            
            valorDevidoAutor = (percentualAdvogadoAutor - address(this).balance);
            
            autor.transfer(valorDevidoAutor);
            advogadoAutor.transfer(address(this).balance);
            valorAcordoRetirado = true;
        }
    
        function pagarSeguroAluguel () payable public {
                require(msg.sender == contaLocatario, "Somente Locatario pode efetuar o pagamento");
                require(msg.value >= valorSeguroAluguel, "Valor insuficiente");
                seguroAluguelPago = true;
            }
        
            function pagamentoNoPrazo () public payable somenteLocador {
                require (now <= dataDeVencimento, "Devedor em mora.");
                require (msg.value == valorAluguel, "Valor diverso do devido");
                parcelasPagas ++;
                emit pagamentoRealizado(msg.value);
            }
    
            function pagarMulta() public payable  {
                require(msg.sender == contaLocatario, "Somente Locatario pode efetuar o pagamento");
                require(msg.value >= 3* valorAluguel, "Valor insuficiente");
                seguroAluguelPago = true;
                emit pagamentoMulta(msg.value);
            }
    
            function fimDoContrato() public {
                require(msg.sender == homologacaoJuizConciliador, "Somente o juízo poderá alterar o status do contrato");
                if (seguroAluguelPago == true && numeroDeParcelas == parcelasPagas) {
                acordoConciliacao = false;
                contaReu.transfer(address(this).balance);
               }
            }
     
    }
