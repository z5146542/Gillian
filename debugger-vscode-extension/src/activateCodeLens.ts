import {
  CodeLens,
  CodeLensProvider,
  commands,
  ExtensionContext,
  languages,
  Range,
  TextDocument,
} from 'vscode';
import { startDebugging } from './commands';
import { ExecMode } from './types';

export function activateCodeLens(context: ExtensionContext) {
  const commandDisposable = commands.registerCommand(
    'extension.gillian-debug.debugProcedure',
    startDebugging
  );

  const supportedLanguages = ['javascript', 'gil', 'wisl'];

  for (const language of supportedLanguages) {
    const docSelector = {
      language: language,
      scheme: 'file',
    };

    const codeLensProviderDisposable = languages.registerCodeLensProvider(
      docSelector,
      new DebugCodeLensProvider()
    );

    context.subscriptions.push(commandDisposable);
    context.subscriptions.push(codeLensProviderDisposable);
  }
}

class DebugCodeLensProvider implements CodeLensProvider {
  async provideCodeLenses(document: TextDocument): Promise<CodeLens[]> {
    const text = document.getText();

    let reProcedure: RegExp;
    switch (document.languageId) {
      case 'gil':
        reProcedure = /proc /g;
        break;
      case 'javascript':
      case 'wisl':
      default:
        reProcedure = /function /g;
        break;
    }

    const reProcedureName = /(.+?)\(/g;

    const lensKinds: [ExecMode, string][] = [
      ['debugverify', 'Verify '],
      ['debugwpst', 'Symbolic-debug '],
    ];
    const lenses: CodeLens[] = [];
    while (reProcedure.exec(text) !== null) {
      reProcedureName.lastIndex = reProcedure.lastIndex;
      const match = reProcedureName.exec(text);
      const procedureName = match === null ? null : match[1].trim();
      if (procedureName) {
        for (const [execMode, commandPrefix] of lensKinds) {
          const codeLens = this.makeCodeLens(
            reProcedureName.lastIndex,
            procedureName,
            document,
            execMode,
            commandPrefix
          );
          if (codeLens !== undefined) {
            lenses.push(codeLens);
          }
        }
      }
    }

    return lenses;
  }

  private makeCodeLens(
    index: number,
    procedureName: string,
    document: TextDocument,
    execMode: ExecMode,
    commandPrefix: string
  ) {
    const startIdx = index - procedureName.length;
    const start = document.positionAt(startIdx);
    const end = document.positionAt(index);
    const range = new Range(start, end);
    const debugConfig = this.createDebugConfig(
      procedureName,
      document.uri.fsPath,
      execMode
    );
    return new CodeLens(range, {
      command: 'extension.gillian-debug.debugProcedure',
      title: commandPrefix + procedureName,
      tooltip: commandPrefix + procedureName,
      arguments: [debugConfig],
    });
  }

  private createDebugConfig(
    procedureName: string,
    program: string,
    execMode: ExecMode
  ) {
    return {
      type: 'gillian',
      name: 'Debug File',
      request: 'launch',
      program: program,
      procedureName: procedureName,
      stopOnEntry: true,
      execMode,
    };
  }
}
