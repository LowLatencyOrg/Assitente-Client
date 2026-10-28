#!/bin/bash

echo "Iniciando configuração do ambiente"

echo "Atualizando pacotes"

	sudo apt update && sudo apt upgrade -y #atualiza os pacotes

if [ $? = 0 ]; then #se retorno for igual a 0 então

    echo "Pacotes atualizados com sucesso!"

else

    echo "Erro ao atualizar os pacotes"
    exit 1

fi

echo "Deseja criar contêiners? [s/n]" 

	read input

    if [ "$input" != "s" ] && [ "$input" != "n" ]; then
        echo "Opcao invalida. Digite s ou n."
        exit 1
    fi

	if [ "$input" = "s" ]; then #se retorno for igual a s então
		
	 	docker --version #verifica versao atual do docker

        if [ $? = 0 ]; #se retorno for igual a 0 então
        then 
        	echo "Você já possui o Docker instalado!" 
	    else 
			echo "Instalando o Docker"
			sudo apt install docker.io -y #instala o docker
			sudo systemctl enable docker #inicia o docker automaticamente sempre que o sistema operacional for inicializado
			sudo systemctl start docker #inicia o docker
			echo "Docker instalado com sucesso!"	

			if [ $? -ne 0 ]; then
            echo "Erro ao instalar ou iniciar o Docker"
            exit 1
        	fi
		fi

		mkdir -p "$HOME/low-latency" #cria diretório low-latency
    	cd "$HOME/low-latency" || exit 1 #entra no diretório 

		echo "Baixando os arquivos do client.JAR"
		if [ -d "captura-rede-java" ]; then #verifica se já existe

        echo "O repositorio do banco ja existe!"

   		else

       		git clone "https://github.com/LowLatencyOrg/captura-rede-java.git" #clona o repositório

    	fi

		cd "$HOME/low-latency/captura-rede-java" || {
            echo "Erro ao acessar o repositorio!"
            exit 1
        }

		echo "Repositorio acessado com sucesso!"
            
        echo "Criando o Dockerfile..."

cat > Dockerfile <<'EOF'
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY java-rede-1.0.jar /app/java-rede-1.0.jar
CMD ["java", "-jar", "/app/java-rede-1.0.jar"]
EOF

        echo "Construindo a imagem Docker..."

        sudo docker build -t low-latency-client . || {
            echo "Erro ao construir a imagem."
            exit 1
        }

        echo "Criando e iniciando o container..."

        sudo docker run --rm --name low-latency-client low-latency-client

        if [ $? -eq 0 ]; then
            echo "Client executado com sucesso!"
        else
            echo "Erro ao executar o client."
            exit 1
        fi

        echo "Verificando os arquivos do projeto..."
        ls -la

        echo "Verificando se o Java esta instalado..."

		if command -v java >/dev/null 2>&1; then #verifica a versão do java
			java -version
			echo "Java ja esta instalado!"
		else
			echo "Java nao encontrado."
            echo "Deseja instalar o Java? [s/n]"
            read -r instalar_java

            if [ "$instalar_java" = "s" ]; then
                sudo apt install default-jre -y || {
                    echo "Erro ao instalar o Java."
                    exit 1
                }
                echo "Java instalado com sucesso!"
            else
                echo "Instalacao cancelada: Java necessario."
                exit 1
            fi
        fi

	else
        mkdir -p "$HOME/low-latency"
        cd "$HOME/low-latency" || exit 1

        echo "Baixando os arquivos do client JAR"

        if [ -d "captura-rede-java" ]; then
            echo "O repositorio ja existe!"
        else
            git clone "https://github.com/LowLatencyOrg/captura-rede-java.git" || {
                echo "Erro ao baixar o repositorio."
                exit 1
            }
        fi

        cd "$HOME/low-latency/captura-rede-java" || {
            echo "Erro ao acessar o repositorio!"
            exit 1
        }

        echo "Repositorio acessado com sucesso!"
        ls -la

        echo "Verificando se o Java esta instalado..."

        if command -v java >/dev/null 2>&1; then
            java -version
            echo "Java ja esta instalado!"
        else
            echo "Java nao encontrado."
            echo "Deseja instalar o Java? [s/n]"
            read -r instalar_java

            if [ "$instalar_java" = "s" ]; then
                sudo apt install default-jre -y || {
                    echo "Erro ao instalar o Java."
                    exit 1
                }
                echo "Java instalado com sucesso!"
            else
                echo "Instalacao cancelada: Java necessario."
                exit 1
            fi
        fi

        echo "Iniciando o client JAR"

        java -jar "$HOME/low-latency/captura-rede-java/java-rede-1.0.jar"

        if [ $? -eq 0 ]; then
            echo "Client executado com sucesso!"
        else
            echo "Erro ao executar o client JAR."
            exit 1
        fi
    fi

echo "Assistente de instalacao finalizado!"