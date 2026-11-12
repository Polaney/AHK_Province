const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

function signFile(filePath, privKeyPath) {
  if (!fs.existsSync(filePath)) {
    throw new Error('File not found: ' + filePath);
  }
  const fileBytes = fs.readFileSync(filePath);
  const hash = crypto.createHash('sha256').update(fileBytes).digest('hex');

  const privKey = fs.readFileSync(privKeyPath, 'utf8');
  const signer = crypto.createSign('SHA256');
  signer.update(fileBytes);
  signer.end();
  const signature = signer.sign(privKey, 'base64');

  return { hash, signature };
}

module.exports = { signFile };

if (require.main === module) {
  const privPath = path.join(__dirname, '..', '.keys', 'release_private_key.pem');
  const exePath = path.join(__dirname, '..', 'АХК УГИБДД.exe');
  const ahkPath = path.join(__dirname, '..', 'АХК УГИБДД.ahk');

  console.log('Signing release files with RSA-SHA256...');
  const exeInfo = signFile(exePath, privPath);
  console.log('EXE SHA256:', exeInfo.hash);
  console.log('EXE Signature (RSA):', exeInfo.signature.substring(0, 32) + '...');

  const ahkInfo = signFile(ahkPath, privPath);
  console.log('AHK SHA256:', ahkInfo.hash);
  console.log('AHK Signature (RSA):', ahkInfo.signature.substring(0, 32) + '...');

  // Update version.json
  const vJsonPath = path.join(__dirname, '..', 'version.json');
  const v = JSON.parse(fs.readFileSync(vJsonPath, 'utf8'));
  v.exe_sha256 = exeInfo.hash;
  v.exe_signature = exeInfo.signature;
  v.ahk_sha256 = ahkInfo.hash;
  v.ahk_signature = ahkInfo.signature;

  fs.writeFileSync(vJsonPath, JSON.stringify(v, null, 2), 'utf8');
  console.log('version.json updated with cryptographic signatures!');
}
