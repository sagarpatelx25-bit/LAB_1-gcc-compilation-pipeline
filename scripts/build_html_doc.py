import os
import base64

base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def get_b64(rel_path):
    full_path = os.path.join(base_dir, rel_path)
    with open(full_path, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode("utf-8")

img1 = get_b64("docs/assets/screenshots/01_step1_source_cat.png")
img2 = get_b64("docs/assets/screenshots/02_step2_preprocessing_gcc_E.png")
img3 = get_b64("docs/assets/screenshots/03_step3_compilation_gcc_S.png")
img4 = get_b64("docs/assets/screenshots/04_step4_assembly_objdump.png")
img5 = get_b64("docs/assets/screenshots/05_step5_linking_file_info.png")
img6 = get_b64("docs/assets/screenshots/06_step6_execution_output.png")

html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>LAB 1: GCC Compilation Pipeline: Step-by-Step Guide</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap');
  body {{
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
    color: #1f2328;
    background: #ffffff;
    max-width: 900px;
    margin: 40px auto;
    padding: 0 30px;
    line-height: 1.65;
  }}
  h1 {{ font-size: 2.2rem; border-bottom: 2px solid #0969da; padding-bottom: 12px; color: #0969da; margin-bottom: 4px; }}
  h2 {{ font-size: 1.5rem; border-bottom: 1px solid #d0d7de; padding-bottom: 8px; margin-top: 35px; color: #1f2328; }}
  h3 {{ font-size: 1.2rem; margin-top: 25px; color: #24292f; }}
  p, li {{ font-size: 15px; color: #24292f; }}
  code {{ font-family: 'JetBrains Mono', monospace; background: #f6f8fa; padding: 2px 6px; border-radius: 4px; font-size: 13.5px; color: #0969da; }}
  pre {{ background: #0d1117; color: #e6edf3; padding: 16px 20px; border-radius: 8px; overflow-x: auto; font-family: 'JetBrains Mono', monospace; font-size: 13.5px; }}
  pre code {{ background: transparent; color: inherit; padding: 0; }}
  table {{ width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 14px; }}
  th, td {{ border: 1px solid #d0d7de; padding: 10px 14px; text-align: left; }}
  th {{ background: #f6f8fa; font-weight: 600; }}
  img {{ max-width: 100%; border-radius: 4px; box-shadow: 0 2px 8px rgba(0,0,0,0.15); margin: 15px 0; border: 1px solid #30363d; background: #0c0c0c; }}
  .badge {{ display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600; background: #ddf4ff; color: #0969da; margin-right: 8px; }}
  .summary-box {{ background: #f6f8fa; border: 1px solid #d0d7de; border-left: 5px solid #0969da; padding: 16px 20px; border-radius: 6px; margin: 25px 0; }}
  @media print {{
    body {{ max-width: 100%; margin: 0; padding: 20px; }}
    pre, img {{ break-inside: avoid; }}
  }}
</style>
</head>
<body>

<h1>LAB 1: GCC Compilation Pipeline: Step-by-Step Guide</h1>
<p><strong>Course:</strong> ST5039CMD Programming and Operating System &bull; <strong>Module:</strong> C-Programming Basics / Integration and Process Concept (Lecture 2 &amp; Lab 1)</p>
<div>
  <span class="badge">GCC Compiler</span>
  <span class="badge">x86-64 Assembly</span>
  <span class="badge">ELF64 Binary</span>
  <span class="badge">Linux Systems</span>
</div>

<div class="summary-box">
  <h2 style="margin-top: 0; border-bottom: none; padding-bottom: 0; color: #0969da;">📌 Executive Summary &amp; Lab Summarization (LAB 1)</h2>
  <p>The primary objective of <strong>LAB 1</strong> is to dissect the modular compilation architecture executed by the <strong>GNU Compiler Collection (GCC)</strong>. Rather than performing a single opaque translation, GCC drives a pipeline of four distinct phases: <strong>Preprocessing</strong>, <strong>Compilation</strong>, <strong>Assembly</strong>, and <strong>Linking</strong>.</p>
  
  <table>
    <thead>
      <tr>
        <th>Stage</th>
        <th>Sub-tool</th>
        <th>GCC Flag</th>
        <th>Input</th>
        <th>Output</th>
        <th>Format</th>
        <th>Primary Responsibility</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>0. Source</strong></td>
        <td>Editor</td>
        <td>—</td>
        <td>—</td>
        <td><code>main.c</code></td>
        <td>Plain text</td>
        <td>Human-readable C code with functions, headers, and statements.</td>
      </tr>
      <tr>
        <td><strong>1. Preprocessing</strong></td>
        <td><code>cpp</code></td>
        <td><code>-E</code></td>
        <td><code>main.c</code></td>
        <td><code>main.i</code></td>
        <td>Expanded C text</td>
        <td>Inlines header files (<code>#include</code>), substitutes macros (<code>#define</code>), strips comments, inserts linemarkers.</td>
      </tr>
      <tr>
        <td><strong>2. Compilation</strong></td>
        <td><code>cc1</code></td>
        <td><code>-S</code></td>
        <td><code>main.i</code></td>
        <td><code>main.s</code></td>
        <td>x86-64 Assembly</td>
        <td>Parses C syntax, generates AST, allocates stack frames and registers, emits target assembly mnemonics.</td>
      </tr>
      <tr>
        <td><strong>3. Assembly</strong></td>
        <td><code>as</code></td>
        <td><code>-c</code></td>
        <td><code>main.s</code></td>
        <td><code>main.o</code></td>
        <td>ELF Relocatable (Binary)</td>
        <td>Translates mnemonics into binary CPU machine opcodes; generates relocation entries for external symbols.</td>
      </tr>
      <tr>
        <td><strong>4. Linking</strong></td>
        <td><code>ld / collect2</code></td>
        <td><code>-o</code></td>
        <td><code>main.o</code></td>
        <td><code>main</code></td>
        <td>ELF Executable (Binary)</td>
        <td>Resolves external symbol references (<code>printf</code>), binds dynamic linker, sets entry point address.</td>
      </tr>
      <tr>
        <td><strong>5. Execution</strong></td>
        <td>Kernel</td>
        <td><code>./main</code></td>
        <td><code>main</code></td>
        <td>stdout</td>
        <td>Console Stream</td>
        <td>OS kernel loads ELF segments into RAM via <code>execve</code>, initiates execution at <code>_start -&gt; main</code>.</td>
      </tr>
    </tbody>
  </table>
</div>

<h2>II. C Program Structure &amp; Compilation Flow</h2>
<pre><code>  [ Source Code: main.c ]
            │
            │  Stage 1: Preprocessing (gcc -E)
            ▼
  [ Preprocessed File: main.i ]
            │
            │  Stage 2: Compilation (gcc -S)
            ▼
  [ Assembly File: main.s ]
            │
            │  Stage 3: Assembly (gcc -c)
            ▼
  [ Relocatable Object: main.o ]
            │
            │  Stage 4: Linking (gcc / ld)
            ▼
  [ Dynamic Executable: main ]
            │
            │  Execution: Kernel execve + ld-linux.so
            ▼
       [ Terminal stdout: "Hello World!" ]</code></pre>

<h2>III. Step-by-Step Practical Demonstration</h2>

<h3>Step 1: Original C Program</h3>
<ul>
  <li><strong>Objective:</strong> View the original source code.</li>
  <li><strong>Command:</strong> <code>cat src/main.c</code></li>
  <li><strong>Image Placeholder:</strong></li>
</ul>
<img src="{img1}" alt="Step 1: Original C Program">
<p><strong>Observation:</strong> Displays the initial C source code written by the programmer with <code>#include &lt;stdio.h&gt;</code> and <code>main()</code> returning 0.</p>

<h3>Step 2: Preprocessing</h3>
<ul>
  <li><strong>Objective:</strong> Process directives like <code>#include</code> and macros to generate the preprocessed source code (<code>.i</code>).</li>
  <li><strong>Command:</strong> <code>gcc -E src/main.c -o stages/01_preprocess/sample_preprocessed_output.i then head -n 30 stages/01_preprocess/sample_preprocessed_output.i</code></li>
  <li><strong>Image Placeholder:</strong></li>
</ul>
<img src="{img2}" alt="Step 2: Preprocessing">
<p><strong>Observation:</strong> The code expands to include standard library declarations, removing comments and resolving macros. Linemarkers preserve debugging traceability.</p>

<h3>Step 3: Compilation</h3>
<ul>
  <li><strong>Objective:</strong> Convert the preprocessed C code into assembly language (<code>.s</code>).</li>
  <li><strong>Command:</strong> <code>gcc -S stages/01_preprocess/sample_preprocessed_output.i -o stages/02_compile/main.s then head -n 30 stages/02_compile/main.s</code></li>
  <li><strong>Image Placeholder:</strong></li>
</ul>
<img src="{img3}" alt="Step 3: Compilation">
<p><strong>Observation:</strong> The compiler translates the C syntax into low-level CPU-specific assembly instructions (AT&amp;T syntax x86-64), allocating stack frames and calling conventions.</p>

<h3>Step 4: Assembly</h3>
<ul>
  <li><strong>Objective:</strong> Convert the assembly instructions into machine-readable object code (<code>.o</code>) and inspect it.</li>
  <li><strong>Command:</strong> <code>gcc -c stages/02_compile/main.s -o stages/03_assemble/main.o then objdump -d stages/03_assemble/main.o</code></li>
  <li><strong>Image Placeholder:</strong></li>
</ul>
<img src="{img4}" alt="Step 4: Assembly">
<p><strong>Observation:</strong> The assembler creates binary machine code. The <code>objdump</code> tool allows viewing raw hex opcodes alongside disassembled mnemonics. Notice external function calls like <code>printf</code> have placeholder offsets.</p>

<h3>Step 5: Linking</h3>
<ul>
  <li><strong>Objective:</strong> Combine the object file with required libraries to create the final executable binary.</li>
  <li><strong>Command:</strong> <code>gcc stages/03_assemble/main.o -o main then file main</code></li>
  <li><strong>Image Placeholder:</strong></li>
</ul>
<img src="{img5}" alt="Step 5: Linking">
<p><strong>Observation:</strong> The linker resolves external function calls (like <code>printf</code>), binds the dynamic loader (<code>/lib64/ld-linux-x86-64.so.2</code>), and creates the final ready-to-run ELF executable.</p>

<h3>Step 6: Execution</h3>
<ul>
  <li><strong>Objective:</strong> Run the final executable program.</li>
  <li><strong>Command:</strong> <code>./main</code></li>
  <li><strong>Image Placeholder:</strong></li>
</ul>
<img src="{img6}" alt="Step 6: Execution">
<p><strong>Observation:</strong> The OS kernel executes the compiled binary via <code>execve</code>, producing the expected output: <code>Hello World!</code>.</p>

</body>
</html>
"""

output_path = os.path.join(base_dir, "LAB_1_GCC_Compilation_Pipeline_Documentation.html")
with open(output_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"Generated LAB 1 HTML report: {output_path}")
