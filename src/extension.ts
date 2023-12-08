// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
import { log } from 'console';
import * as vscode from 'vscode';

type CommentBranch = {
	parent?: CommentBranch
	prev?: CommentBranch
	levelNum: number
	charsLength: number
	subBranches: CommentBranch[]
};

const decorationType = vscode.window.createTextEditorDecorationType({
	// Define the styling here
	after: {
		color: new vscode.ThemeColor('editorLineNumber.foreground'), // Use theme color for compatibility
	},
});

const hideDecorationType = vscode.window.createTextEditorDecorationType({
	// This will set the text color to the same as the background, effectively "hiding" it
	color: new vscode.ThemeColor('editor.background'),
	rangeBehavior: vscode.DecorationRangeBehavior.ClosedClosed,
});


function updateDecorations() {
	const activeEditor = vscode.window.activeTextEditor;
	if (!activeEditor) {
		return;
	}

	const text = activeEditor.document.getText();
	const regEx = /^(\s*\/\/\s*)(#+)/gm;
	const decorations: vscode.DecorationOptions[] = [];
	const hidedecorations: vscode.DecorationOptions[] = [];

	let match;

	let prevLevelNumberList: number[] = [];
	while ((match = regEx.exec(text))) {
		const startPos = activeEditor.document.positionAt(match.index);
		const cursorPosition = activeEditor.selection.start;
		if (cursorPosition.line === startPos.line) { 
			continue; 
		}
		const endPos = activeEditor.document.positionAt(match.index + match[0].length);
		const capturedChars: string = match[2];
		let currentLevelNumberList: number[] = [];
		// it is the same level between the current level and the prev level,
		// so that increat 1 in the last element in the prevLevelNumberList
		if (capturedChars.length === prevLevelNumberList.length) {
			currentLevelNumberList = prevLevelNumberList;
			currentLevelNumberList[currentLevelNumberList.length - 1]++;
		//	The current level is greater than the previous level, so eliminate unnecessary sub-levels, which are one level up from the current level, and add the one
		} else if (capturedChars.length < prevLevelNumberList.length) {
			currentLevelNumberList = prevLevelNumberList.slice(0, capturedChars.length);
			currentLevelNumberList[currentLevelNumberList.length - 1]++;
		// the current level is less than the previous level, 
		} else {
			currentLevelNumberList = prevLevelNumberList;
			for (let i = 1; i <= capturedChars.length - prevLevelNumberList.length; i++) {
				currentLevelNumberList.push(1);
			}
		}
		const numberComment = currentLevelNumberList.join('.');
		prevLevelNumberList = currentLevelNumberList;
		// set the numberical comments
		const decoration: vscode.DecorationOptions = {
			range: new vscode.Range(startPos, endPos),
			renderOptions: {
				after: {
					contentText: numberComment,
					color: new vscode.ThemeColor('editorLineNumber.foreground'), // Use theme color for compatibility
					margin: `0 0 0 -${currentLevelNumberList.length * .6}em`
				},
			},
		};
		decorations.push(decoration);
		// Decoration to "hide" the hashes
		const hideDecoration: vscode.DecorationOptions = { 
			range: new vscode.Range(
				activeEditor.document.positionAt(match.index + match[1].length),
			activeEditor.document.positionAt(match.index + match[1].length + match[2].length)
			) 
		};

		hidedecorations.push(hideDecoration);
	}

	activeEditor.setDecorations(decorationType, decorations);
	activeEditor.setDecorations(hideDecorationType, hidedecorations);
}

// This method is called when your extension is activated
// Your extension is activated the very first time the command is executed
export function activate(context: vscode.ExtensionContext) {
	if (vscode.window.activeTextEditor) {
		log("activeTextEditor");
    }

    // * Handle extensions being added or removed
    vscode.extensions.onDidChange(() => {
		log("onDidChange");
    }, null, context.subscriptions);

    // * Handle active file changed
    vscode.window.onDidChangeActiveTextEditor(async editor => {
		log("onDidChangeActiveTextEditor");
		editor && updateDecorations();
    }, null, context.subscriptions);

    // * Handle file contents changed
    vscode.workspace.onDidChangeTextDocument(event => {
		log("ChangeTextDocument");
		vscode.window.activeTextEditor && event.document === vscode.window.activeTextEditor.document && updateDecorations();
    }, null, context.subscriptions);

	vscode.workspace.onDidOpenTextDocument(event => {
		log("onDidOpenTextDocument");
		updateDecorations();
	}, null, context.subscriptions);

}

// This method is called when your extension is deactivated
export function deactivate() {}
