
# Inventário de máquinas agricolas

Este projeto é um estudo da máteria de aplicaticos móveis 2, ele tem como objetivo usar da linguagem flutter para desenvolver um aplicativo que conecte-se a um web service para pegar informações e cadastrar elas.

O principal objetivo é possibilitar o usuário de ver e cadastrar máquinas que possuem tipo e marca. No aplicativo, tem a opção de buscar os dados do web service e armazenar eles no banco de dados local, quando o aplicativo está offline, é possível gerar cadastros e edições e sincronizar com o web service depois quando houver uma conexão, tendo as mudanças salvas no banco local até a sincronização acontecer.

## Autores

- [@emanuellemachado](https://www.github.com/Emanuelle-Machado)


## Funcionalidades

- Listar máquinas do web service
- Filtrar e buscar máquinas
- Cadastrar máquinas no web service
- Cadastrar tipo e marca no web service
- Layout vertical e horizontal, com possibilidade de rodar em outros dispositivos.


## Stack utilizada

**Front-end:** Flutter

**Back-end:** Dart


## 📑 Endpoints da API
urlBase: https://argo.td.utfpr.edu.br/maquinas/ws

| Método | Endpoint                                     | Descrição                                                                |
|--------|----------------------------------------------|--------------------------------------------------------------------------|
| GET    | `maquina`                                    | Retorna todas as máquinas                                                |
| GET    | `tipo`                                       | Retorna todos os tipos de máquinas                                       |
| GET    | `marca`                                      | Retorna todas as raças                                                   |
| GET    | `cidade`                                     | Retorna todas as marcas                                                  |
| GET    | `animal/{id}`                                | Retorna uma máquina específico pelo ID                                   |
| GET    | `tipo/{id}`                                  | Retorna um tipo específico pelo ID                                       |
| GET    | `marca/{id}`                                 | Retorna uma marca específica pelo ID                                     |

## Aprendizados

Neste projeto aprendi mais sobre o uso de flutter e dart em aplicativos mobile para melhorar. Além de aprender a realizar a conexão com o web service.


## Screenshots

<h3 align="center">Página inicial</h3>
<p align="center">
  <img src="https://github.com/Emanuelle-Machado/AdotarPets/blob/master/app/src/main/assets/imglimpa.jpeg" alt="Página inicial" width="200"/>
  <img src="https://github.com/Emanuelle-Machado/AdotarPets/blob/master/app/src/main/assets/imgpreenchida.jpeg" alt="Listagem de animais" width="200"/>
  
</p>

<h3 align="center">Cadastros</h3>
<p align="center">
  <img src="https://github.com/Emanuelle-Machado/AdotarPets/blob/master/app/src/main/assets/animais.jpeg" alt="Cadastro de Animais" width="200"/>
  <img src="https://github.com/Emanuelle-Machado/AdotarPets/blob/master/app/src/main/assets/cidade.jpeg" alt="Dialogo de cadastro de cidade" width="200"/>
  <img src="https://github.com/Emanuelle-Machado/AdotarPets/blob/master/app/src/main/assets/raca.jpeg" alt="Dialogo de cadastro de raças" width="200"/>
  <img src="https://github.com/Emanuelle-Machado/AdotarPets/blob/master/app/src/main/assets/tipo.jpeg" alt="Dialogo de cadastro de tipos" width="200"/>
</p>

<h3 align="center">Todas as telas tem sua versão horizontal</h3>
<p align="center">
  <img src="https://github.com/Emanuelle-Machado/AdotarPets/blob/master/app/src/main/assets/horizontal.jpeg" alt="Imagem na horizontal" height="200"/>
</p>

