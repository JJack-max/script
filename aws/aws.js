// 获取题目文本
let question = document.querySelector('.qusetion-title')?.innerText || "";

// 获取选项文本
let options = Array.from(document.querySelectorAll('.options-w .option')).map(opt => {
    let label = opt.querySelector('.before-icon')?.innerText || "";
    let text = opt.querySelector('span:nth-child(2)')?.innerText || "";
    return `${label}. ${text}`;
});

const output = `${question}
${options.join('\n')}`;

console.log(output);