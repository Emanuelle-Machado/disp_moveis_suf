// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Types`
  String get tipos {
    return Intl.message('Types', name: 'tipos', desc: '', args: []);
  }

  /// `Description`
  String get descricao {
    return Intl.message('Description', name: 'descricao', desc: '', args: []);
  }

  /// `Enter the description`
  String get informeDescricao {
    return Intl.message(
      'Enter the description',
      name: 'informeDescricao',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get cadastrar {
    return Intl.message('Register', name: 'cadastrar', desc: '', args: []);
  }

  /// `Save`
  String get salvar {
    return Intl.message('Save', name: 'salvar', desc: '', args: []);
  }

  /// `Confirm removal`
  String get confirmarRemocao {
    return Intl.message(
      'Confirm removal',
      name: 'confirmarRemocao',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to remove the type "{descricao}"?`
  String desejaRemoverTipo(Object descricao) {
    return Intl.message(
      'Do you want to remove the type "$descricao"?',
      name: 'desejaRemoverTipo',
      desc: '',
      args: [descricao],
    );
  }

  /// `Cancel`
  String get cancelar {
    return Intl.message('Cancel', name: 'cancelar', desc: '', args: []);
  }

  /// `Remove`
  String get remover {
    return Intl.message('Remove', name: 'remover', desc: '', args: []);
  }

  /// `No brands registered.`
  String get nenhumaMarcaCadastrada {
    return Intl.message(
      'No brands registered.',
      name: 'nenhumaMarcaCadastrada',
      desc: '',
      args: [],
    );
  }

  /// `Brands`
  String get marcas {
    return Intl.message('Brands', name: 'marcas', desc: '', args: []);
  }

  /// `New Brand`
  String get novaMarca {
    return Intl.message('New Brand', name: 'novaMarca', desc: '', args: []);
  }

  /// `Register Brand`
  String get cadastrarMarca {
    return Intl.message(
      'Register Brand',
      name: 'cadastrarMarca',
      desc: '',
      args: [],
    );
  }

  /// `Edit Brand`
  String get editarMarca {
    return Intl.message('Edit Brand', name: 'editarMarca', desc: '', args: []);
  }

  /// `Name`
  String get nome {
    return Intl.message('Name', name: 'nome', desc: '', args: []);
  }

  /// `Enter the name`
  String get informeNome {
    return Intl.message(
      'Enter the name',
      name: 'informeNome',
      desc: '',
      args: [],
    );
  }

  /// `Remove Brand`
  String get removerMarca {
    return Intl.message(
      'Remove Brand',
      name: 'removerMarca',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to remove the brand "{nome}"?`
  String desejaRemoverMarca(Object nome) {
    return Intl.message(
      'Do you want to remove the brand "$nome"?',
      name: 'desejaRemoverMarca',
      desc: '',
      args: [nome],
    );
  }

  /// `Machines`
  String get maquinas {
    return Intl.message('Machines', name: 'maquinas', desc: '', args: []);
  }

  /// `Register Machine`
  String get cadastrarMaquina {
    return Intl.message(
      'Register Machine',
      name: 'cadastrarMaquina',
      desc: '',
      args: [],
    );
  }

  /// `Edit Machine`
  String get editarMaquina {
    return Intl.message(
      'Edit Machine',
      name: 'editarMaquina',
      desc: '',
      args: [],
    );
  }

  /// `Remove Machine`
  String get removerMaquina {
    return Intl.message(
      'Remove Machine',
      name: 'removerMaquina',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove "{descricao}"?`
  String temCertezaRemoverMaquina(Object descricao) {
    return Intl.message(
      'Are you sure you want to remove "$descricao"?',
      name: 'temCertezaRemoverMaquina',
      desc: '',
      args: [descricao],
    );
  }

  /// `Register Machine`
  String get tooltipCadastrarMaquina {
    return Intl.message(
      'Register Machine',
      name: 'tooltipCadastrarMaquina',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'pt'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
