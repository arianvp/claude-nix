{
  lib,
  claudeLib,
  pandoc,
  texliveSmall,
  writeShellApplication,
}:
let
  pandoc' = writeShellApplication {
    name = "pandoc";
    runtimeInputs = [ pandoc texliveSmall ];
    text = ''
      exec pandoc "$@"
    '';
  };
in
claudeLib.mkSkill {
  name = "pandoc";
  description = "Convert between document types";
  allowed-tools = "Bash(${lib.getExe pandoc'}:*)";
  content = ''

    ## How to use

    ```
    ${lib.getExe pandoc'} <input>> -o <output>.<format>
    ```

    ## Supported formats and other options

    See
    ```
    ${lib.getExe pandoc'} --help
    ```

    ## Examples

    ### Markdown to word

    Plain:
    ```
    ${lib.getExe pandoc'} input.md -o output.docx
    ```

    With Table of Contents:
    ```
    ${lib.getExe pandoc'} input.md -o output.docx --toc
    ```

    ### Markdown to PDF

    Plain:
    ```
    ${lib.getExe pandoc'} input.md -o output.pdf
    ```

    With Table of Contents:
    ```
    ${lib.getExe pandoc'} input.md -o output.pdf --toc
    ```


  '';
}
