module.exports = {
  extends: [
    'smarthr',
  ],
  plugins: [
    'import'
  ],
  rules: {
    'no-console': 'error',
    'react/react-in-jsx-scope': 'off',
    'arrow-body-style': 'error',
    'smarthr/require-barrel-import': 'error',
    'smarthr/a11y-input-has-name-attribute': 'off',
    'smarthr/a11y-input-in-form-control': 'off',
    '@typescript-eslint/no-unused-vars': [
      'error',
      {
        argsIgnorePattern: '^_', // 引数で_から始まる変数は無視する
        varsIgnorePattern: '^_', // 変数で_から始まる変数は無視する
        caughtErrorsIgnorePattern: '^_', // catchで_から始まる変数は無視する
        destructuredArrayIgnorePattern: '^_', // 分割代入で_から始まる変数は無視する
      },
    ],
  },
}
