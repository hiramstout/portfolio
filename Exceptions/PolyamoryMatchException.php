<?php

namespace App\Services\Exceptions;

use Throwable;

class PolyamoryMatchException extends \Exception implements Throwable
{
    public PolyamoryMatchExceptionEnum $exceptionType;
    public function __construct(
        PolyamoryMatchExceptionEnum $exceptionType,
        string                      $message = '',
        ?string                     $fileName = null,
        ?string                     $funcName = null,
        ?Throwable                  $previous = null,
    ) {
        $this->exceptionType = $exceptionType;
        $message .= '. Exception Type: ' . $exceptionType->getLabel();
        $message .= $fileName ? '. Exception from file: ' . $fileName : '';
        $message .= $funcName ? '. Function name: ' . $funcName : '';
        parent::__construct($message, $exceptionType->value, $previous);
    }
}
