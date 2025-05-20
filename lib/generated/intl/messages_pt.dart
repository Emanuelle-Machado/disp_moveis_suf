// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pt locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'pt';

  static String m0(nome) => "Deseja remover a marca \"${nome}\"?";

  static String m1(descricao) => "Deseja remover o tipo \"${descricao}\"?";

  static String m2(descricao) =>
      "Tem certeza que deseja remover \"${descricao}\"?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "cadastrar": MessageLookupByLibrary.simpleMessage("Cadastrar"),
    "cadastrarMaquina": MessageLookupByLibrary.simpleMessage(
      "Cadastrar Máquina",
    ),
    "cadastrarMarca": MessageLookupByLibrary.simpleMessage("Cadastrar Marca"),
    "cancelar": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "confirmarRemocao": MessageLookupByLibrary.simpleMessage(
      "Confirmar remoção",
    ),
    "descricao": MessageLookupByLibrary.simpleMessage("Descrição"),
    "desejaRemoverMarca": m0,
    "desejaRemoverTipo": m1,
    "editarMaquina": MessageLookupByLibrary.simpleMessage("Editar Máquina"),
    "editarMarca": MessageLookupByLibrary.simpleMessage("Editar Marca"),
    "informeDescricao": MessageLookupByLibrary.simpleMessage(
      "Informe a descrição",
    ),
    "informeNome": MessageLookupByLibrary.simpleMessage("Informe o nome"),
    "maquinas": MessageLookupByLibrary.simpleMessage("Máquinas"),
    "marcas": MessageLookupByLibrary.simpleMessage("Marcas"),
    "nenhumaMarcaCadastrada": MessageLookupByLibrary.simpleMessage(
      "Nenhuma marca cadastrada.",
    ),
    "nome": MessageLookupByLibrary.simpleMessage("Nome"),
    "novaMarca": MessageLookupByLibrary.simpleMessage("Nova Marca"),
    "remover": MessageLookupByLibrary.simpleMessage("Remover"),
    "removerMaquina": MessageLookupByLibrary.simpleMessage("Remover Máquina"),
    "removerMarca": MessageLookupByLibrary.simpleMessage("Remover Marca"),
    "salvar": MessageLookupByLibrary.simpleMessage("Salvar"),
    "temCertezaRemoverMaquina": m2,
    "tipos": MessageLookupByLibrary.simpleMessage("Tipos"),
    "tooltipCadastrarMaquina": MessageLookupByLibrary.simpleMessage(
      "Cadastrar Máquina",
    ),
  };
}
