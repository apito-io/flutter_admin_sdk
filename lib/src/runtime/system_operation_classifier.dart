/// Classifies GraphQL documents before they are sent with a bootstrap key.
///
/// This is deliberately a small GraphQL document reader rather than a regular
/// expression. It understands aliases, arguments, directives, inline
/// fragments, named fragments, and comments/strings, so a client-side guard
/// cannot be bypassed by changing the spelling or layout of a document.
enum SystemOperationClass {
  ordinary,
  privileged,
}

const _privilegedSystemFields = <String>{
  'createTenant',
  'updateTenant',
  'deleteTenant',
  'generateTenantToken',
  'getTenants',
  'searchTenants',
  'searchUsers',
  'createUser',
  'updateUser',
  'resetUserPassword',
  'deleteUser',
  'getProjectPlans',
  'getModelData',
  'getSingleData',
  'upsertModelData',
  'deleteModelData',
  'debug',
  'projectModelInfo',
  'listSingleModelHasMany',
  'countPhotosInfo',
  'loadedFunctionProvider',
  'listAvailableFunctions',
  'rearrangeFieldOfModel',
};

SystemOperationClass classifySystemOperation(String document) {
  final parser = _GraphqlDocumentParser(document);
  if (!parser.parse()) {
    // The server remains authoritative, but a bootstrap credential must never
    // be allowed through an unparseable document.
    return SystemOperationClass.privileged;
  }
  return parser.rootFields.any(_privilegedSystemFields.contains)
      ? SystemOperationClass.privileged
      : SystemOperationClass.ordinary;
}

enum _TokenKind {
  name,
  punctuation,
  value,
}

class _Token {
  const _Token(this.text, this.kind);

  final String text;
  final _TokenKind kind;

  bool get isName => kind == _TokenKind.name;
}

class _GraphqlDocumentParser {
  _GraphqlDocumentParser(String source) : _source = source;

  final String _source;
  final rootFields = <String>{};
  final _operations = <int>[];
  final _fragments = <String, int>{};
  late List<_Token> _tokens;

  bool parse() {
    final tokens = _tokenize(_source);
    if (tokens == null || tokens.isEmpty) return false;
    _tokens = tokens;

    var index = 0;
    while (index < _tokens.length) {
      final token = _tokens[index];
      if (token.text == '{') {
        _operations.add(index);
        final end = _skipBalanced(index, '{', '}');
        if (end == null) return false;
        index = end;
        continue;
      }

      if (!token.isName) return false;
      switch (token.text) {
        case 'query':
        case 'mutation':
        case 'subscription':
          final next = _parseOperation(index + 1);
          if (next == null) return false;
          index = next;
          continue;
        case 'fragment':
          final next = _parseFragment(index + 1);
          if (next == null) return false;
          index = next;
          continue;
        default:
          // A GraphQL executable document has no other top-level definition.
          return false;
      }
    }

    if (_operations.isEmpty) return false;
    for (final operation in _operations) {
      if (!_collectSelection(operation, true, <String>{})) return false;
    }
    return true;
  }

  int? _parseOperation(int index) {
    // An operation name is optional. A variable definition starts with "(".
    if (index < _tokens.length &&
        _tokens[index].isName &&
        !_isDirectiveOrSelectionStart(_tokens[index])) {
      index++;
    }
    if (index < _tokens.length && _tokens[index].text == '(') {
      index = _skipBalanced(index, '(', ')') ?? -1;
      if (index < 0) return null;
    }
    index = _skipDirectives(index);
    if (index < 0 || index >= _tokens.length || _tokens[index].text != '{') {
      return null;
    }
    _operations.add(index);
    return _skipBalanced(index, '{', '}');
  }

  int? _parseFragment(int index) {
    if (index >= _tokens.length || !_tokens[index].isName) return null;
    final name = _tokens[index].text;
    index++;
    if (index >= _tokens.length || _tokens[index].text != 'on') return null;
    index++;
    if (index >= _tokens.length || !_tokens[index].isName) return null;
    index++; // Type condition.
    index = _skipDirectives(index);
    if (index < 0 || index >= _tokens.length || _tokens[index].text != '{') {
      return null;
    }
    if (_fragments.containsKey(name)) return null;
    _fragments[name] = index;
    return _skipBalanced(index, '{', '}');
  }

  bool _collectSelection(
    int start,
    bool root,
    Set<String> visitingFragments,
  ) {
    if (start >= _tokens.length || _tokens[start].text != '{') return false;
    var index = start + 1;
    while (index < _tokens.length) {
      final token = _tokens[index];
      if (token.text == '}') return true;

      if (token.text == '...') {
        index++;
        if (index >= _tokens.length) return false;

        if (_tokens[index].text == 'on') {
          index++;
          if (index >= _tokens.length || !_tokens[index].isName) {
            return false;
          }
          index++;
          index = _skipDirectives(index);
          if (index < 0 || index >= _tokens.length) return false;
          if (!_collectSelection(index, root, visitingFragments)) return false;
          index = _skipBalanced(index, '{', '}') ?? -1;
          if (index < 0) return false;
          continue;
        }

        if (!_tokens[index].isName) return false;
        final fragmentName = _tokens[index].text;
        index = _skipDirectives(index + 1);
        if (index < 0) return false;
        if (!root) continue;
        final fragmentStart = _fragments[fragmentName];
        if (fragmentStart == null) return false;
        if (!visitingFragments.add(fragmentName)) return false;
        final ok = _collectSelection(
          fragmentStart,
          true,
          visitingFragments,
        );
        visitingFragments.remove(fragmentName);
        if (!ok) return false;
        continue;
      }

      if (!token.isName) return false;
      var fieldName = token.text;
      index++;
      // Alias: aliasName: actualFieldName.
      if (index < _tokens.length && _tokens[index].text == ':') {
        index++;
        if (index >= _tokens.length || !_tokens[index].isName) return false;
        fieldName = _tokens[index].text;
        index++;
      }
      if (root) rootFields.add(fieldName);

      if (index < _tokens.length && _tokens[index].text == '(') {
        index = _skipBalanced(index, '(', ')') ?? -1;
        if (index < 0) return false;
      }
      index = _skipDirectives(index);
      if (index < 0) return false;
      if (index < _tokens.length && _tokens[index].text == '{') {
        if (!_collectSelection(index, false, visitingFragments)) return false;
        index = _skipBalanced(index, '{', '}') ?? -1;
        if (index < 0) return false;
      }
    }
    return false;
  }

  int _skipDirectives(int index) {
    while (index >= 0 && index < _tokens.length && _tokens[index].text == '@') {
      index++;
      if (index >= _tokens.length || !_tokens[index].isName) return -1;
      index++;
      if (index < _tokens.length && _tokens[index].text == '(') {
        index = _skipBalanced(index, '(', ')') ?? -1;
      }
    }
    return index;
  }

  int? _skipBalanced(int start, String open, String close) {
    if (start >= _tokens.length || _tokens[start].text != open) return null;
    var depth = 0;
    for (var index = start; index < _tokens.length; index++) {
      final text = _tokens[index].text;
      if (text == open) depth++;
      if (text == close) depth--;
      if (depth == 0) return index + 1;
    }
    return null;
  }

  bool _isDirectiveOrSelectionStart(_Token token) {
    return token.text == '@' || token.text == '{';
  }
}

List<_Token>? _tokenize(String source) {
  final tokens = <_Token>[];
  var index = 0;
  while (index < source.length) {
    final code = source.codeUnitAt(index);
    if (_isIgnoredCode(code)) {
      index++;
      continue;
    }
    if (code == 35) {
      while (index < source.length &&
          source.codeUnitAt(index) != 10 &&
          source.codeUnitAt(index) != 13) {
        index++;
      }
      continue;
    }
    if (source.startsWith('"""', index)) {
      final end = source.indexOf('"""', index + 3);
      if (end < 0) return null;
      tokens.add(const _Token('', _TokenKind.value));
      index = end + 3;
      continue;
    }
    if (code == 34) {
      index++;
      var escaped = false;
      var closed = false;
      while (index < source.length) {
        final next = source.codeUnitAt(index);
        index++;
        if (escaped) {
          escaped = false;
        } else if (next == 92) {
          escaped = true;
        } else if (next == 34) {
          closed = true;
          break;
        }
      }
      if (!closed) return null;
      tokens.add(const _Token('', _TokenKind.value));
      continue;
    }
    if (_isNameStart(code)) {
      final start = index;
      index++;
      while (
          index < source.length && _isNameContinue(source.codeUnitAt(index))) {
        index++;
      }
      tokens.add(_Token(source.substring(start, index), _TokenKind.name));
      continue;
    }
    if (code == 46 && source.startsWith('...', index)) {
      tokens.add(const _Token('...', _TokenKind.punctuation));
      index += 3;
      continue;
    }
    if (_isNumberStart(code)) {
      final start = index;
      index++;
      while (index < source.length &&
          (_isNumberContinue(source.codeUnitAt(index)) ||
              source.codeUnitAt(index) == 46)) {
        index++;
      }
      tokens.add(_Token(source.substring(start, index), _TokenKind.value));
      continue;
    }
    if (r'!$&():=@[]{|}'.codeUnits.contains(code)) {
      tokens.add(_Token(String.fromCharCode(code), _TokenKind.punctuation));
      index++;
      continue;
    }
    // Commas are insignificant in GraphQL and were handled above.
    if (code == 44) {
      index++;
      continue;
    }
    return null;
  }
  return tokens;
}

bool _isIgnoredCode(int code) {
  return code == 9 || code == 10 || code == 13 || code == 32 || code == 65279;
}

bool _isNameStart(int code) {
  return (code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122) ||
      code == 95;
}

bool _isNameContinue(int code) {
  return _isNameStart(code) || (code >= 48 && code <= 57);
}

bool _isNumberStart(int code) {
  return (code >= 48 && code <= 57) || code == 45;
}

bool _isNumberContinue(int code) {
  return (code >= 48 && code <= 57) ||
      code == 45 ||
      code == 43 ||
      code == 69 ||
      code == 101;
}
