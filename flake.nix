{
  description = "Demand-driven personal agent skills";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      checks.${system}.structure = pkgs.runCommand "agent-skills-structure" { } ''
        fail() {
          echo "error: $*" >&2
          exit 1
        }

        for skill in ${self}/skills/*; do
          [ -d "$skill" ] || continue
          file="$skill/SKILL.md"
          [ -f "$file" ] || fail "$skill is missing SKILL.md"

          name="$(${pkgs.gawk}/bin/awk '
            NR == 1 && $0 != "---" { exit 1 }
            NR > 1 && $0 == "---" { closed = 1; exit }
            /^name:[[:space:]]*/ { sub(/^name:[[:space:]]*/, ""); print; found = 1 }
            END { if (!found || !closed) exit 1 }
          ' "$file")" || fail "$file has invalid frontmatter or no name"
          [ "$name" = "$(basename "$skill")" ] || fail "$file name does not match directory"

          description="$(${pkgs.gawk}/bin/awk '
            NR == 1 && $0 != "---" { exit 1 }
            NR > 1 && $0 == "---" { closed = 1; exit }
            /^description:[[:space:]]*/ {
              sub(/^description:[[:space:]]*/, "")
              gsub(/^[[:space:]]+|[[:space:]]+$/, "")
              if ($0 == "" || $0 == "\"\"" || $0 == sprintf("%c%c", 39, 39)) exit 1
              print
              found = 1
            }
            END { if (!found || !closed) exit 1 }
          ' "$file")" || fail "$file has invalid frontmatter or empty description"
          [ "$(${pkgs.coreutils}/bin/wc -l < "$file")" -lt 500 ] || fail "$file has 500 or more lines"
        done

        for view in agents claude; do
          for target in ${self}/targets/"$view"/*; do
            [ -L "$target" ] || fail "$target is not a symlink"
            [ -e "$target" ] || fail "$target does not resolve"
          done
        done

        touch "$out"
      '';

      formatter.${system} = pkgs.nixfmt-tree;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          nixfmt
        ];
      };
    };
}
